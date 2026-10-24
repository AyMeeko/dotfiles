"""Exercise copied V2 config with a disposable server, never the shared service."""
import json
import os
from pathlib import Path
import secrets
import selectors
import shutil
import subprocess
import tempfile
import time
from urllib.parse import urlparse

REPO = Path(__file__).resolve().parents[1]
temporary = Path("/tmp/opencode")
temporary.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix="dotfiles-runtime-", dir=temporary) as directory:
    root = Path(directory)
    home = root / "home"
    project = home / "project"
    project.mkdir(parents=True)
    config = root / "config/opencode"
    shutil.copytree(REPO / "home/dot_config/opencode", config)
    settings = json.loads((config / "opencode.json").read_text())
    settings["update"] = "disable"
    (config / "opencode.json").write_text(json.dumps(settings))
    (root / "tmp").mkdir()
    env = {
        "PATH": os.environ["PATH"], "HOME": str(home),
        "XDG_CONFIG_HOME": str(root / "config"), "XDG_DATA_HOME": str(root / "data"),
        "XDG_CACHE_HOME": str(root / "cache"), "XDG_STATE_HOME": str(root / "state"),
        "TMPDIR": str(root / "tmp"), "OPENCODE_PASSWORD": secrets.token_urlsafe(32),
    }

    def command(*args, timeout=30):
        result = subprocess.run(["opencode", *args], cwd=project, env=env,
                                capture_output=True, text=True, timeout=timeout)
        assert result.returncode == 0, result.stderr or result.stdout
        return result.stdout.strip()

    assert command("debug", "paths", "config") == str(config), "config isolation failed"
    with (root / "server.log").open("w+") as logs:
        server = subprocess.Popen([
            "opencode", "serve", "--stdio", "--hostname", "127.0.0.1", "--port", "0",
        ], cwd=project, env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=logs, text=True)
        try:
            with selectors.DefaultSelector() as selector:
                selector.register(server.stdout, selectors.EVENT_READ)
                assert selector.select(timeout=45), "private server startup timed out"
                handshake = json.loads(server.stdout.readline())
            url = handshake["url"]
            assert urlparse(url).hostname == "127.0.0.1", handshake

            def api(path, body=None):
                args = ["api", "--server", url, "get" if body is None else "post", path]
                if body is not None:
                    args.extend(["--data", json.dumps(body)])
                return json.loads(command(*args))

            deadline = time.monotonic() + 180
            expected = {"betterplan-build-switch", "superpowers-write-guard", "superpowers", "plannotator"}
            while True:
                response = api("/api/plugin")
                entries = response["data"]
                active = {entry.get("id") for entry in entries
                          if entry.get("state", {}).get("status") == "active"}
                if expected <= active:
                    break
                assert time.monotonic() < deadline, response
                time.sleep(0.5)
            failures = [entry for entry in entries if entry.get("state", {}).get("status") == "failed"]
            assert not failures, failures

            def definitions(path):
                response = api(path)
                assert response["location"]["directory"] == str(project), response
                return response["data"]

            agents = definitions("/api/agent")
            assert {"betterplan", "investigate", "oracle", "librarian", "code-reviewer", "opencode-expert"} <= {a["id"] for a in agents}, agents
            assert not any(a["id"] == "plan" and not a.get("disabled", False) for a in agents), agents
            for agent in agents:
                if agent["id"] not in {"betterplan", "investigate", "oracle", "librarian", "code-reviewer", "opencode-expert"}:
                    continue
                rules = agent["permissions"]
                assert {"action": "edit", "resource": "*", "effect": "deny"} in rules, agent
                if agent["id"] in {"betterplan", "investigate"}:
                    assert any(rule["action"] == "edit" and rule["effect"] == "allow"
                               and rule["resource"].endswith("/notes/ai/**") for rule in rules), agent
                else:
                    assert {"action": "subagent", "resource": "*", "effect": "deny"} in rules, agent
            # Exercise the host's actual permission evaluator, without model calls
            # or executing shell commands. A blanket shell deny breaks reviews.
            review = api("/api/session", {"agent": "code-reviewer", "location": {"directory": str(project)}})["data"]
            for resource, expected_effect in [
                ("git status --short", "allow"),
                ("git diff HEAD --", "allow"),
                ("git --no-pager diff HEAD --", "allow"),
                ("git show HEAD:README.md", "allow"),
                ("git rev-parse HEAD", "allow"),
                ("git ls-files --others --exclude-standard", "allow"),
                ("git commit -m unauthorized", "deny"),
                ("git reset --hard", "deny"),
                ("git diff --output=README.md", "deny"),
                ("git diff --ext-diff", "deny"),
                ("git show --textconv HEAD:README.md", "deny"),
                ("touch README.md", "deny"),
            ]:
                permission = api(f'/api/session/{review["id"]}/permission', {
                    "action": "shell", "resources": [resource], "agent": "code-reviewer",
                })["data"]
                assert permission["effect"] == expected_effect, (resource, permission)
            skills = definitions("/api/skill")
            assert {"feature-dossier", "session-routing", "save-plans-to-notes", "using-superpowers"} <= {s["id"] for s in skills}, skills
            assert "git-dance" not in {s["id"] for s in skills}
            commands = definitions("/api/command")
            assert {"plannotator-review", "plannotator-annotate", "plannotator-last"} <= {c["name"] for c in commands}, commands
            assert not (config / "node_modules").exists(), "plugins require deployed dependency install"
            print("PASS: copied agents/skills/commands and all four plugins active on isolated OpenCode V2")
        except BaseException:
            logs.flush()
            logs.seek(0)
            print(logs.read()[-12000:])
            raise
        finally:
            if server.stdin:
                server.stdin.close()
            server.terminate()
            try:
                server.wait(timeout=10)
            except subprocess.TimeoutExpired:
                server.kill()
                server.wait()
