"""Check the binary-only setup with mocked downloads; never installs live tools."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]
SOURCE = REPO / "home/dot_config/opencode"
config = json.loads((SOURCE / "opencode.json").read_text())
assert config["default_agent"] == "betterplan"
assert config["agents"]["plan"]["disabled"]
assert config["plugins"][1]["options"]["workflow"] == "manual"
assert "mcp" not in config and "skills" not in config
assert not (SOURCE / "tui.json").exists()
assert not (SOURCE / "skills/git-dance/SKILL.md").exists()
json.loads((SOURCE / "cli.json").read_text())
for path in SOURCE.rglob("*"):
    if path.is_file():
        text = path.read_text()
        for unwanted in ["/Users/", "gusto", "zenpayroll", "notes/ai/tickets/", "acli", "bktide"]:
            assert unwanted not in text, (path, unwanted)

MOCK = '''#!/usr/bin/env python3
import hashlib, os, pathlib, sys
root = pathlib.Path(os.environ["TEST_ROOT"])
with (root / "downloads").open("a") as log:
    log.write(" ".join(sys.argv[1:]) + "\\n")
if (root / "fail-download").exists():
    sys.exit(22)
target = pathlib.Path(sys.argv[sys.argv.index("-o") + 1])
body = b"#!/bin/sh\\necho plannotator-test\\n"
if target.name.endswith(".sha256"):
    checksum = "0" * 64 if (root / "bad-checksum").exists() else hashlib.sha256(body).hexdigest()
    target.write_text(checksum + "  " + target.name.removesuffix(".sha256") + "\\n")
else:
    target.write_bytes(body)
'''

with tempfile.TemporaryDirectory(prefix="opencode-setup-") as directory:
    root = Path(directory)
    home = root / "home"
    home.mkdir()
    tools = root / "bin"
    tools.mkdir()
    for name, body in {"curl": MOCK, "uname": "#!/bin/sh\necho x86_64\n"}.items():
        target = tools / name
        target.write_text(body)
        target.chmod(0o755)
    env = dict(os.environ, HOME=str(home), PATH=f"{tools}:/usr/bin:/bin", TEST_ROOT=str(root))
    local = root / "chezmoi.toml"

    def render(role="omarchy", enabled=True):
        local.write_text(f'[data]\nrole="{role}"\nsetupEnabled={str(enabled).lower()}\n')
        return subprocess.check_output([
            "chezmoi", "--source", str(REPO), "--config", str(local), "execute-template",
            "--file", str(REPO / "home/run_once_after_22-opencode-tools.sh.tmpl"),
        ], env=env, text=True)

    assert not render(enabled=False).strip()
    assert not render(role="wsl").strip()
    script = render()

    def run(ok=True):
        result = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
        assert (result.returncode == 0) == ok, result.stderr
        assert not list((home / ".local/bin").glob(".plannotator-install.*")), "download residue"

    for failure in ["bad-checksum", "fail-download"]:
        (root / failure).touch()
        run(ok=False)
        assert not (home / ".local/bin/plannotator").exists()
        (root / failure).unlink()
    run()
    binary = home / ".local/bin/plannotator"
    assert os.access(binary, os.X_OK)
    downloads = (root / "downloads").read_text()
    assert "/v0.28.7/plannotator-linux-x64" in downloads
    binary.write_text("user-selected installation\n")
    run()
    assert binary.read_text() == "user-selected installation\n"
    assert (root / "downloads").read_text() == downloads
    assert not (home / ".config").exists(), "installer touched managed config"
print("PASS: personal OpenCode scope, setup guards, checksum/failure recovery and repeat install")
