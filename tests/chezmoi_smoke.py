"""Exercise the real chezmoi CLI without touching the operator's home."""
import os
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile

REPO = Path(__file__).resolve().parents[1]
STAGE = sys.argv[1] if len(sys.argv) > 1 else "base"


def check(condition, message):
    if not condition:
        raise AssertionError(message)


def profile(root, role="omarchy", internal="/dev/input/by-path/test-internal", external=""):
    home = root / "home"
    home.mkdir()
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / ".config"),
               XDG_DATA_HOME=str(home / ".local/share"), XDG_CACHE_HOME=str(home / ".cache"))
    config = root / "chezmoi.toml"
    config.write_text(f'[data]\nrole = "{role}"\nkmonadInternalDevice = "{internal}"\n'
                       f'kmonadExternalDevice = "{external}"\nsetupEnabled = false\n')
    args = ["chezmoi", "--source", str(REPO), "--destination", str(home),
            "--config", str(config), "--persistent-state", str(root / "state.boltdb"),
            "--cache", str(root / "cache"), "--no-pager"]

    def run(*command, success=True):
        result = subprocess.run(args + list(command), env=env, text=True, capture_output=True)
        if success:
            check(result.returncode == 0, f'{command}: {result.stderr}')
        else:
            check(result.returncode != 0, f'{command} unexpectedly succeeded')
        return result
    return home, run


def deploy(role, internal, external):
    with tempfile.TemporaryDirectory(prefix="dotfiles-chezmoi-") as directory:
        root = Path(directory)
        home, run = profile(root, role, internal, external)
        other = home / ".config/other-app/keep"
        other.parent.mkdir(parents=True)
        other.write_text("local state")
        branding = home / ".config/omarchy/branding/local-art.txt"
        branding.parent.mkdir(parents=True)
        branding.write_text("keep branding")
        unit = home / ".config/systemd/user/unrelated.service"
        unit.parent.mkdir(parents=True)
        unit.write_text("keep service")
        known_hosts = home / ".ssh/known_hosts"
        known_hosts.parent.mkdir(mode=0o700)
        known_hosts.write_text("existing known hosts")
        run("apply", "--dry-run", "--verbose")
        run("apply", "--no-tty")
        check(not run("diff").stdout, "fresh apply left a diff")
        run("apply", "--no-tty")
        check(not run("diff").stdout, "second apply not idempotent")
        check(other.read_text() == "local state", "unrelated config changed")
        check(branding.read_text() == "keep branding", "unrelated branding changed")
        check(unit.read_text() == "keep service", "unrelated service changed")
        check(known_hosts.read_text() == "existing known hosts", "SSH host history changed")
        for path in [".ssh/config", ".config/autostart/com.onepassword.OnePassword.desktop",
                     ".config/environment.d/10-1password.conf"]:
            check((home / path).is_file() == (role == "omarchy"), f"wrong SSH role: {path}")
        if role == "omarchy":
            check((home / ".ssh").stat().st_mode & 0o777 == 0o700, "SSH directory permissions")
            check((home / ".ssh/config").stat().st_mode & 0o777 == 0o600, "SSH config permissions")
            result = subprocess.run(["ssh", "-G", "-F", str(home / ".ssh/config"), "github.com"],
                                    capture_output=True, text=True)
            check(result.returncode == 0, result.stderr)
            check(f"identityagent {Path.home()}/.1password/agent.sock\n" in result.stdout, "wrong SSH agent")
            check("user git\n" in result.stdout, "wrong GitHub SSH user")
        for path in [".zshrc", ".config/nvim/init.lua", ".config/nvim/lazy-lock.json",
                     ".config/tmux/tmux.conf", ".config/tmux/cht.sh",
                     ".config/tmux/new_workspace.sh", ".config/opencode/opencode.json",
                     ".config/omz-custom/themes/my-theme.zsh-theme"]:
            target = home / path
            check(target.is_file() and not target.is_symlink(), f"not a regular file: {path}")
        check(os.access(home / ".config/tmux/new_workspace.sh", os.X_OK), "helper not executable")
        check(not (home / "README.md").exists(), "repo docs deployed")
        check(not (home / ".config/nvim/README.md").exists(), "Neovim docs deployed")
        check(not (home / ".config/karabiner").exists(), "macOS files deployed")
        check(not (home / ".dotfiles").exists(), "legacy alias deployed")
        check(not (home / ".config/.keep").exists(), "placeholder deployed")
        if STAGE in ("desktop", "kmonad"):
            for path in [".config/ghostty/config", ".config/xdg-terminals.list",
                         ".config/omarchy/branding/screensaver.txt"]:
                check((home / path).is_file() == (role == "omarchy"), f"wrong role: {path}")
            if role == "omarchy":
                source = REPO / "home/dot_config/omarchy/branding/screensaver.txt"
                check((home / ".config/omarchy/branding/screensaver.txt").read_bytes() == source.read_bytes(),
                      "screensaver bytes changed")
        if STAGE == "kmonad":
            for name in ["kmonad", "kmonad-external"]:
                enabled = role == "omarchy" and (name == "kmonad" or bool(external))
                kbd = home / f".config/kmonad/{name}.kbd"
                unit = home / f".config/systemd/user/{name}.service"
                check(kbd.is_file() == enabled and unit.is_file() == enabled, f"wrong keyboard pair: {name}")
                if enabled:
                    device = internal if name == "kmonad" else external
                    check(device in kbd.read_text(), "wrong keyboard input")
                    check(f'%h/.config/kmonad/{name}.kbd' in unit.read_text(), "service uses source checkout")
                    if name == "kmonad-external":
                        check(f'ExecCondition=/usr/bin/test -e "{device}"' in unit.read_text(),
                              "absent external keyboard would cause restart loop")
                    result = subprocess.run(["kmonad", "--dry-run", str(kbd)], capture_output=True, text=True)
                    check(result.returncode == 0, result.stderr + result.stdout)
                    result = subprocess.run(["systemd-analyze", "--user", "verify", str(unit)],
                                            capture_output=True, text=True)
                    check(result.returncode == 0, result.stderr + result.stdout)
    return


def test_init():
    """Exercise init, not just hand-written test data passed to apply."""
    for role in ("omarchy", "wsl"):
        with tempfile.TemporaryDirectory(prefix="dotfiles-init-") as directory:
            root = Path(directory)
            home, run = profile(root, role)
            # Start with no config so prompt flags must supply first-init values.
            (root / "chezmoi.toml").unlink()
            run("init", "--promptChoice", f"Machine role={role}",
                "--promptBool", "Install dependencies and activate services=false",
                "--promptString", "Internal keyboard device (/dev/input/by-id/ or by-path/)=/dev/input/by-path/init-test,External keyboard device (empty to omit)=")
            import tomllib
            config = tomllib.loads((root / "chezmoi.toml").read_text())
            check(config["sourceDir"] == str(REPO), "init recorded managed subtree instead of checkout")
            data = config["data"]
            check(data["role"] == role, "init lost role")
            if role == "omarchy":
                check(data["kmonadInternalDevice"] == "/dev/input/by-path/init-test", "init lost device")
            run("apply", "--no-tty")
            # A re-init must retain previous device data rather than asking again.
            run("init", "--no-tty")


def test_legacy_migration():
    with tempfile.TemporaryDirectory(prefix="dotfiles-migrate-") as directory:
        root = Path(directory)
        home, run = profile(root)
        old = root / "old-checkout/nvim"
        old.mkdir(parents=True)
        (old / "init.lua").write_text("local edits")
        (old / "untracked.txt").write_text("local untracked")
        link = home / ".config/nvim"
        link.parent.mkdir()
        link.symlink_to(old, target_is_directory=True)
        backup = root / "backup/nvim"
        shutil.copytree(link, backup)
        link.unlink()  # Only the link; never its source directory.
        run("apply", "--dry-run")
        run("apply", "--no-tty")
        check(not link.is_symlink(), "legacy link survived")
        check((old / "init.lua").read_text() == "local edits", "wrote through old link")
        check((backup / "untracked.txt").read_text() == "local untracked", "backup lost untracked data")
        check((link / "init.lua").read_bytes() == (REPO / "home/dot_config/nvim/init.lua").read_bytes(),
              "did not deploy copied config")
        # Real-directory conflict requires a decision, with no partial overwrite.
        (link / "init.lua").write_text("conflicting user edit")
        run("apply", "--error-on-conflict", success=False)
        check((link / "init.lua").read_text() == "conflicting user edit", "conflict destroyed edit")


def test_setup_scripts():
    for role in ("omarchy", "wsl"):
        with tempfile.TemporaryDirectory(prefix="dotfiles-scripts-") as directory:
            _, run = profile(Path(directory), role=role)
            for source in sorted((REPO / "home").glob("run_*.tmpl")):
                script = run("execute-template", "--override-data", '{"setupEnabled":true}',
                             "--file", str(source)).stdout
                check(bool(script.strip()) == (role == "omarchy"), "script crossed role boundary")
                result = subprocess.run(["bash", "-n"], input=script, capture_output=True, text=True)
                check(result.returncode == 0, f"{source}: {result.stderr}")


check((REPO / ".chezmoiroot").is_file(), "chezmoi source root is missing")
test_setup_scripts()
deploy("omarchy", "/dev/input/by-path/test-internal", "")
deploy("omarchy", "/dev/input/by-id/another-machine", "/dev/input/by-id/test-external")
deploy("wsl", "", "")
with tempfile.TemporaryDirectory(prefix="dotfiles-invalid-") as directory:
    _, run = profile(Path(directory), role="invalid")
    check("role" in run("apply", success=False).stderr, "invalid role error unclear")
if STAGE == "kmonad":
    with tempfile.TemporaryDirectory(prefix="dotfiles-missing-device-") as directory:
        _, run = profile(Path(directory), internal="")
        check("kmonadInternalDevice" in run("apply", success=False).stderr, "missing input error unclear")
    test_init()
    test_legacy_migration()
print(f"PASS: {STAGE} deployment, role guards, permissions and idempotence")
