"""Exercise guarded Weylus setup without installing packages or starting a server."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib

REPO = Path(__file__).resolve().parents[1]
SCRIPT = REPO / "home/run_once_after_24-weylus.sh.tmpl"

temporary_parent = "/tmp/opencode" if Path("/tmp/opencode").is_dir() else None
with tempfile.TemporaryDirectory(prefix="weylus-smoke-", dir=temporary_parent) as directory:
    root = Path(directory)
    tools = root / "bin"
    tools.mkdir()
    config_home = root / "config with spaces"
    env = dict(os.environ, HOME=str(root), XDG_CONFIG_HOME=str(config_home),
               XDG_DATA_HOME=str(root / "other data"), XDG_CACHE_HOME=str(root / "cache"),
               PATH=f"{tools}:{os.environ['PATH']}", TEST_ROOT=str(root))
    mock = '''#!/usr/bin/env python3
import json, os, pathlib, sys
root = pathlib.Path(os.environ["TEST_ROOT"])
name = pathlib.Path(sys.argv[0]).name
with (root / "calls").open("a") as log:
    log.write(json.dumps([name, *sys.argv[1:]]) + "\\n")
if name == "pacman":
    if sys.argv[1:] == ["-Q", "weylus-pinned"]:
        if not (root / "installed").exists():
            sys.exit(1)
        print("weylus-pinned " + (root / "installed").read_text())
    sys.exit(0)
if name == "sudo":
    sys.exit(1)
if name == "makepkg":
    if "--packagelist" in sys.argv:
        print(str(pathlib.Path.cwd() / "weylus-pinned-0.11.4.38a01a8-1-x86_64.pkg.tar.zst"))
    elif (root / "fail").exists():
        sys.exit(1)
    else:
        pathlib.Path("weylus-pinned-0.11.4.38a01a8-1-x86_64.pkg.tar.zst").touch()
if name == "pkexec" and "-U" in sys.argv:
    assert pathlib.Path(sys.argv[-1]).is_file()
    if (root / "fail-install").exists():
        sys.exit(1)
    (root / "installed").write_text("0.11.4.38a01a8-1")
'''
    for name in ["pacman", "makepkg", "sudo", "pkexec"]:
        tool = tools / name
        tool.write_text(mock)
        tool.chmod(0o755)

    def render(role="omarchy", enabled=True):
        config = root / "chezmoi.toml"
        config.write_text(f'[data]\nrole="{role}"\nsetupEnabled={str(enabled).lower()}\n'
                          'kmonadInternalDevice="/dev/input/test-keyboard"\n')
        result = subprocess.run([
            "chezmoi", "--source", str(REPO), "--config", str(config),
            "execute-template", "--file", str(SCRIPT),
        ], env=env, text=True, capture_output=True)
        assert result.returncode == 0, result.stderr
        return result.stdout

    assert not render(enabled=False).strip()
    assert not render(role="wsl").strip()
    script = render()
    package_dir = root / ".local/share/dotfiles/weylus"
    package_dir.mkdir(parents=True)
    for name in ["PKGBUILD", "pointer-regression.rs"]:
        source = REPO / "home/dot_local/share/dotfiles/weylus" / name
        assert source.exists(), f"Missing pinned package input: {name}"
        (package_dir / name).write_bytes(source.read_bytes())
    target = config_home / "weylus/weylus.toml"
    (root / "fail").touch()
    failed = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
    assert failed.returncode != 0
    assert not target.exists(), "Failed installs must remain retryable"
    (root / "fail").unlink()
    subprocess.run(["bash"], input=script, env=env, text=True, check=True)
    calls = [json.loads(line) for line in (root / "calls").read_text().splitlines()]
    assert any(call[0] == "makepkg" and "--cleanbuild" in call for call in calls), calls
    assert any(call[0] == "makepkg" and "--check" in call for call in calls), calls
    assert any(call[:3] == ["pkexec", "/usr/bin/pacman", "-U"] for call in calls), calls
    settings = tomllib.loads(target.read_text())
    assert settings["wayland_support"] is True
    assert settings["auto_start"] is False and settings["no_gui"] is False
    assert settings["web_port"] == 1701
    assert "access_code" not in settings
    assert target.stat().st_mode & 0o777 == 0o600
    original = target.read_text() + '\naccess_code = "local-only"\n'
    target.write_text(original)
    (root / "calls").unlink()
    subprocess.run(["bash"], input=script, env=env, text=True, check=True)
    assert target.read_text() == original, "Repeat setup must preserve saved access codes/settings"
    calls = [json.loads(line) for line in (root / "calls").read_text().splitlines()]
    assert not any(call[0] in ["makepkg", "pkexec"] for call in calls), calls

    # Failed upgrades must not replace settings or masquerade as installed builds.
    (root / "installed").write_text("0.11.4.old-1")
    (root / "fail-install").touch()
    failed = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
    assert failed.returncode != 0
    assert target.read_text() == original
    assert (root / "installed").read_text() == "0.11.4.old-1"
    (root / "fail-install").unlink()
    subprocess.run(["bash"], input=script, env=env, text=True, check=True)
    assert target.read_text() == original
    assert (root / "installed").read_text() == "0.11.4.38a01a8-1"

    for role in ["omarchy", "wsl"]:
        render(role=role)
        managed = subprocess.check_output([
            "chezmoi", "--source", str(REPO), "--config", str(root / "chezmoi.toml"),
            "managed", "--include", "files",
        ], env=env, text=True).splitlines()
        for name in [".local/share/applications/weylus.desktop",
                     ".local/share/dotfiles/weylus/PKGBUILD",
                     ".local/share/dotfiles/weylus/pointer-regression.rs"]:
            assert (name in managed) == (role == "omarchy"), (role, name)

print("Weylus setup checks passed")
