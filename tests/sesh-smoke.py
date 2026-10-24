"""Exercise sesh helpers and guarded installation without opening a picker or changing sessions."""
import json
import fcntl
import os
from pathlib import Path
import pty
import select
import shutil
import signal
import struct
import subprocess
import tempfile
import termios
import time
import tomllib

REPO = Path(__file__).resolve().parents[1]
HELPER = REPO / "home/dot_config/tmux/executable_sesh-picker.sh"
TMUX = shutil.which("tmux")
FZF = shutil.which("fzf")
MOCK = '''#!/usr/bin/env python3
import json,os,pathlib,sys
root = pathlib.Path(os.environ["TEST_ROOT"])
name = pathlib.Path(sys.argv[0]).name
with (root / "commands.jsonl").open("a") as log:
    log.write(json.dumps([name,*sys.argv[1:]]) + "\\n")
if name == "sesh" and sys.argv[1] == "list":
    if "--format" in sys.argv:
        print("dev with spaces\\t dev with spaces\\nnotes/\\t notes/")
    else:
        print(" dev with spaces\\n📁 ~/src/another project")
elif name == "fzf-tmux":
    (root / "fzf-args.json").write_text(json.dumps(sys.argv[1:]))
    sys.stdin.read()
    print(os.environ.get("PICKER_RESULT", " dev with spaces"))
    sys.exit(int(os.environ.get("PICKER_STATUS", "0")))
elif name == "tmux" and sys.argv[1] == "display-message":
    print(os.environ.get("CURRENT_SESSION", "dev"))
elif name == "pacman":
    sys.exit(0 if (root / "installed").exists() else 1)
elif name == "omarchy":
    if (root / "fail-install").exists():
        sys.exit(1)
    (root / "installed").touch()
'''

with tempfile.TemporaryDirectory(prefix="sesh-smoke-", dir="/tmp/opencode") as directory:
    root = Path(directory)
    tools = root / "bin"
    tools.mkdir()
    home = root / "home"
    home.mkdir()
    for name in ["sesh", "fzf-tmux", "tmux", "pacman", "omarchy"]:
        path = tools / name
        path.write_text(MOCK)
        path.chmod(0o755)
    env = dict(os.environ, HOME=str(home), TEST_ROOT=str(root), PATH=f"{tools}:{os.environ['PATH']}")
    log = root / "commands.jsonl"

    def commands():
        return [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []

    def helper(*args, **overrides):
        log.unlink(missing_ok=True)
        result = subprocess.run(["bash", str(HELPER), *args], env=dict(env, **overrides),
                                capture_output=True, text=True)
        return result, commands()

    selected = " dev with spaces; touch not-a-command"
    result, calls = helper(PICKER_RESULT=selected)
    assert result.returncode == 0, result.stderr
    assert ["sesh", "list", "--icons", "--hide-attached", "--tmux"] in calls, calls
    assert ["sesh", "connect", selected] in calls, calls
    fzf = json.loads((root / "fzf-args.json").read_text())
    assert fzf[:2] == ["-p", "80%,70%"]
    assert fzf[fzf.index("--preview") + 1] == "sesh preview {}"
    assert fzf[fzf.index("--preview-window") + 1] == "right:55%"
    bindings = [fzf[index + 1] for index, arg in enumerate(fzf) if arg == "--bind"]
    for key, command in [("ctrl-a", "sesh list --icons"), ("ctrl-t", "sesh list -t --icons"),
                         ("ctrl-g", "sesh list -c --icons"), ("ctrl-x", "sesh list -z --icons")]:
        assert any(binding.startswith(key + ":") and f"reload({command})" in binding for binding in bindings), bindings
    assert any(binding.startswith("ctrl-f:") and "fd -H -d 2 -t d" in binding for binding in bindings)
    kill = next(binding for binding in bindings if binding.startswith("ctrl-d:"))
    action = kill.split("execute(", 1)[1].split(")+", 1)[0]
    deployed = home / ".config/tmux/sesh-picker.sh"
    deployed.parent.mkdir(parents=True)
    shutil.copyfile(HELPER, deployed)
    deployed.chmod(0o755)

    def fzf_action(row):
        """Let real fzf expand its placeholders on an isolated pseudo-terminal."""
        log.unlink(missing_ok=True)
        child_env = dict(env, TERM="xterm-256color", SHELL="/bin/bash", FZF_DEFAULT_OPTS="",
                         FZF_DEFAULT_COMMAND='printf "%s\\n" "$SESH_TEST_ROW"', SESH_TEST_ROW=row)
        child_env.pop("FZF_DEFAULT_OPTS_FILE", None)
        pid, terminal = pty.fork()
        if pid == 0:
            fcntl.ioctl(1, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 100, 0, 0))
            os.execve(FZF, [FZF, "--no-sort", "--ansi", "--bind", f"load:execute-silent({action})+abort"], child_env)
        finished = False
        try:
            deadline = time.monotonic() + 10
            while time.monotonic() < deadline:
                if select.select([terminal], [], [], 0.1)[0]:
                    try:
                        if not os.read(terminal, 65536):
                            break
                    except OSError:
                        break
                if os.waitpid(pid, os.WNOHANG)[0]:
                    finished = True
                    break
            else:
                raise AssertionError("fzf action timed out")
        finally:
            os.close(terminal)
            if not finished:
                try:
                    os.kill(pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
                os.waitpid(pid, 0)
        return [call for call in commands() if call[:2] == ["tmux", "kill-session"]]

    assert fzf_action(" dev with spaces") == [["tmux", "kill-session", "-t", "=dev with spaces"]]
    for row in ["/home/user/src/dev notes/", "📁 /home/user/src/dev notes/", " notes/", " nonexistent"]:
        assert fzf_action(row) == [], row

    for status, selection in [("130", ""), ("1", ""), ("0", "")]:
        result, calls = helper(PICKER_STATUS=status, PICKER_RESULT=selection)
        assert result.returncode == 0, result.stderr
        assert not any(call[:2] == ["sesh", "connect"] for call in calls), calls
    result, _ = helper(PICKER_STATUS="2", PICKER_RESULT="")
    assert result.returncode == 2
    result, calls = helper("notes", CURRENT_SESSION="dev")
    assert result.returncode == 0 and calls[-1] == ["sesh", "connect", "--switch", "notes"], (result.stderr, calls)
    result, calls = helper("notes", CURRENT_SESSION="notes")
    assert result.returncode == 0 and calls[-1] == ["sesh", "last"], (result.stderr, calls)

    config = root / "chezmoi.toml"

    def render(role="omarchy", enabled=True):
        config.write_text(f'[data]\nrole="{role}"\nsetupEnabled={str(enabled).lower()}\n')
        return subprocess.check_output([
            "chezmoi", "--source", str(REPO), "--config", str(config), "execute-template", "--file",
            str(REPO / "home/run_once_after_21-sesh.sh.tmpl"),
        ], env=env, text=True)

    assert not render(enabled=False).strip()
    assert not render(role="wsl").strip()
    script = render()
    log.unlink(missing_ok=True)
    (root / "fail-install").touch()
    result = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
    assert result.returncode != 0 and not (root / "installed").exists()
    (root / "fail-install").unlink()
    subprocess.run(["bash"], input=script, env=env, text=True, check=True)
    assert ["omarchy", "pkg", "aur", "add", "sesh-bin"] in commands(), commands()
    log.unlink()
    subprocess.run(["bash"], input=script, env=env, text=True, check=True)
    assert not any(call[0] == "omarchy" for call in commands()), commands()

    # Parse the real config on a disposable tmux socket, never the user's server.
    theme = home / ".config/tmux-plugins/catppuccin/tmux/catppuccin.tmux"
    theme.parent.mkdir(parents=True)
    theme.write_text("#!/bin/sh\nexit 0\n")
    theme.chmod(0o755)
    socket = str(root / "tmux.sock")
    tmux_env = dict(env)
    tmux_env.pop("TMUX", None)
    tmux_env.pop("TMUX_PANE", None)

    def tmux(*args):
        return subprocess.check_output([TMUX, "-S", socket, *args], env=tmux_env, text=True)

    try:
        tmux("-f", str(REPO / "home/dot_config/tmux/tmux.conf"), "new-session", "-d", "-s", "sesh-smoke", "-c", str(home))
        assert "sesh-picker.sh" in tmux("list-keys", "-T", "prefix", "t")
        assert "sesh last" in tmux("list-keys", "-T", "prefix", "K")
        assert 'sesh-picker.sh' in tmux("list-keys", "-T", "prefix", "J")
        rename = tmux("list-keys", "-T", "prefix", "R")
        assert 'command-prompt -I "#{session_name}" -p "Rename session:"' in rename, rename
        assert "rename-session '%%'" in rename, rename
        assert tmux("show-options", "-gv", "detach-on-destroy").strip() == "off"
        # Supply the theme-module boundary without requiring installed plugins;
        # real tmux must render the configured session text dynamically.
        tmux("set-option", "-g", "@catppuccin_status_session", "#{E:@catppuccin_session_text}")
        assert tmux("display-message", "-p", "-t", "sesh-smoke", "#{E:status-left}").strip() == "sesh-smoke"
        tmux("rename-session", "-t", "sesh-smoke", "sesh-renamed")
        assert tmux("display-message", "-p", "-t", "sesh-renamed", "#{E:status-left}").strip() == "sesh-renamed"
    finally:
        subprocess.run([TMUX, "-S", socket, "kill-server"], env=tmux_env, capture_output=True)
    notes = tomllib.loads((REPO / "home/dot_config/sesh/sesh.toml").read_text())
    assert notes["session"] == [{"name": "notes", "path": "~/notes"}]
    subprocess.run(["zsh", "-n", str(REPO / "home/dot_zshrc")], check=True)
print("PASS: sesh picker/cancellation/notes, guarded install and real isolated tmux bindings")
