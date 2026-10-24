"""Exercise real TPM/Resurrect/Continuum on a disposable socket and copied plugins."""
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import time

REPO = Path(__file__).resolve().parents[1]
TMUX = shutil.which("tmux")
PS = shutil.which("ps")
assert TMUX and PS, "tmux and ps are required"
installed = Path.home() / ".tmux/plugins"
theme = Path.home() / ".config/tmux-plugins/catppuccin/tmux"
assert all((installed / name).is_dir() for name in ["tpm", "tmux-resurrect", "tmux-continuum"]), "Install tmux plugins first"
assert theme.is_dir(), "Install the pinned Catppuccin theme first"

with tempfile.TemporaryDirectory(prefix="tmux-plugin-runtime-", dir="/tmp/opencode") as directory:
    root = Path(directory)
    home = root / "home"
    home.mkdir()
    for name in ["tpm", "tmux-resurrect", "tmux-continuum"]:
        shutil.copytree(installed / name, home / ".tmux/plugins" / name,
                        symlinks=True, ignore=shutil.ignore_patterns(".git"))
    shutil.copytree(theme, home / ".config/tmux-plugins/catppuccin/tmux",
                    symlinks=True, ignore=shutil.ignore_patterns(".git"))
    socket = str(root / "tmux.sock")
    tools = root / "bin"
    tools.mkdir()
    # Every upstream script uses this wrapper, even when it drops its TMUX env.
    wrapper = tools / "tmux"
    wrapper.write_text("#!/bin/sh\nexec " + shlex.join([TMUX, "-S", socket]) + ' "$@"\n')
    wrapper.chmod(0o755)
    # Continuum invokes systemctl even with @continuum-boot off. Never let a
    # disposable test enable/disable units on the operator's real user manager.
    systemctl = tools / "systemctl"
    systemctl.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> ' + shlex.quote(str(root / "systemctl.log")) + "\n")
    systemctl.chmod(0o755)
    # Continuum intentionally avoids auto-restore/autosave if another server
    # exists. Simulate a sole-server process inventory for that one query only;
    # forward Resurrect's real process-inspection queries unchanged.
    ps = tools / "ps"
    ps.write_text("#!/bin/sh\n"
                  'if [ "$1" = "-u" ] && [ "$3" = "-o" ] && [ "$4" = "command pid" ]; then\n'
                  '  printf "COMMAND PID\\ntmux %s\\n" "$(printf %s "$TMUX" | cut -d, -f2)"\n'
                  "else\n  exec " + shlex.quote(PS) + ' "$@"\nfi\n')
    ps.chmod(0o755)
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / ".config"),
               XDG_DATA_HOME=str(home / ".local/share"), XDG_STATE_HOME=str(home / ".local/state"),
               XDG_CACHE_HOME=str(home / ".cache"), PATH=f"{tools}:{os.environ['PATH']}",
               XDG_RUNTIME_DIR=str(root / "runtime"),
               DBUS_SESSION_BUS_ADDRESS=f"unix:path={root / 'no-session-bus'}")
    (root / "runtime").mkdir(mode=0o700)
    env.pop("TMUX", None)
    env.pop("TMUX_PANE", None)
    restored = root / "restored"
    config = home / ".config/tmux/tmux.conf"
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text(f"set -g @resurrect-hook-post-restore-all 'touch {restored}'\n" +
                      (REPO / "home/dot_config/tmux/tmux.conf").read_text())
    # Avoid a startup restore racing the initial test snapshot; remove before
    # the restart that actually exercises automatic restoration.
    halt = home / "tmux_no_auto_restore"
    halt.touch()
    first = home / "project-a"
    second = home / "project-b"
    first.mkdir()
    second.mkdir()

    def tmux(*args):
        result = subprocess.run([str(wrapper), *args], env=env, text=True, capture_output=True)
        assert result.returncode == 0, (args, result.stderr)
        return result.stdout.strip()

    def wait_for(check, description, timeout=15):
        deadline = time.monotonic() + timeout
        while True:
            if check():
                return
            assert time.monotonic() < deadline, description
            time.sleep(0.05)

    def start(name):
        tmux("-f", str(config), "new-session", "-d", "-s", name, "-x", "120", "-y", "40", "-c", str(first))
        env["TMUX"] = f'{socket},{tmux("display-message", "-p", "#{pid}")},0'

    def panes():
        return sorted(tmux("list-panes", "-a", "-F", "#S|#I|#P|#{pane_current_path}|#{pane_left}|#{pane_top}|#{pane_width}|#{pane_height}").splitlines())

    def stop():
        pid = env.get("TMUX", ",,").split(",")[1]
        subprocess.run([str(wrapper), "kill-server"], env=env, capture_output=True)
        if pid:
            def exited():
                try:
                    state = Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()[0]
                except FileNotFoundError:
                    return True
                return state == "Z"
            # kill-server acknowledges before the old process releases its socket.
            wait_for(exited, "old disposable tmux server did not exit")
        env.pop("TMUX", None)

    try:
        start("persist-me")
        save = tmux("show-option", "-gqv", "@resurrect-save-script-path")
        assert save.endswith("/tmux-resurrect/scripts/save.sh"), "TPM did not load Resurrect"
        service_calls = root / "systemctl.log"
        assert service_calls.is_file(), "Continuum's service-management call escaped test capture"
        assert "--user disable tmux.service" in service_calls.read_text()
        assert "save.sh" in tmux("list-keys", "-T", "prefix", "C-s")
        assert "restore.sh" in tmux("list-keys", "-T", "prefix", "C-r")
        assert "install_plugins" in tmux("list-keys", "-T", "prefix", "I")
        assert tmux("show-option", "-gqv", "@continuum-save-interval") == "15"
        assert tmux("show-option", "-gqv", "@continuum-restore") == "on"
        assert tmux("show-option", "-gqv", "@continuum-boot") == "off"
        assert tmux("show-option", "-gqv", "@resurrect-capture-pane-contents") == "off"
        status = tmux("show-option", "-gqv", "status-right")
        assert status.count("continuum_save.sh") == 1, "autosave hook lost or duplicated"
        assert "%m-%d-%y" in status, "clock overwritten by plugin load"
        tmux("split-window", "-h", "-t", "persist-me:0", "-c", str(second))
        tmux("new-window", "-t", "persist-me", "-n", "second", "-c", str(first))
        subprocess.run([save, "quiet"], env=env, check=True, capture_output=True)
        snapshot = home / ".local/share/tmux/resurrect/last"
        assert snapshot.is_file() and "persist-me" in snapshot.read_text()
        # Trigger a due autosave through the real script rather than waiting 15m.
        tmux("new-window", "-t", "persist-me", "-n", "autosaved", "-c", str(second))
        snapshot_second = int(snapshot.stat().st_mtime)
        wait_for(lambda: int(time.time()) > snapshot_second, "next snapshot timestamp")
        tmux("set-option", "-g", "@continuum-save-last-timestamp", "0")
        subprocess.run([str(home / ".tmux/plugins/tmux-continuum/scripts/continuum_save.sh")],
                       env=env, check=True, capture_output=True)
        wait_for(lambda: snapshot.is_file() and "autosaved" in snapshot.read_text(), "autosave did not update local snapshot")
        expected = panes()
        assert len(expected) == 4, expected
        assert not (snapshot.parent / "pane_contents.tar.gz").exists()
        stop()
        halt.unlink()
        start("scratch")
        wait_for(restored.exists, "automatic restore did not complete on server startup")
        actual = panes()
        assert [pane for pane in actual if pane.startswith("persist-me|")] == expected, (actual, expected)
        assert any(pane.startswith("scratch|") for pane in actual), "restore removed an existing session"
        tmux("source-file", str(config))
        assert tmux("show-option", "-gqv", "status-right").count("continuum_save.sh") == 1
        assert not (home / ".config/systemd/user/tmux.service").exists(), "unexpected login autostart"
        print("PASS: real TPM bindings, manual save, due autosave, startup restore, layouts/cwds and reload hook")
    finally:
        stop()
