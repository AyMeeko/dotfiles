"""Verify bootstrap wiring without installing packages or changing services."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="dotfiles-bootstrap-") as directory:
    root = Path(directory)
    bin_dir = root / "bin"
    bin_dir.mkdir()
    home = root / "home"
    home.mkdir()
    log = root / "commands.jsonl"
    for name, contents in {
        "omarchy": "#!/bin/sh\nexit 0\n",
        "chezmoi": "#!/usr/bin/env python3\nimport json,os,sys\n"
                   "with open(os.environ['BOOTSTRAP_LOG'], 'a') as f:\n"
                   "    f.write(json.dumps(sys.argv[1:])+'\\n')\n",
    }.items():
        path = bin_dir / name
        path.write_text(contents)
        path.chmod(0o755)
    primary, external = root / "primary", root / "external"
    primary.touch()
    external.touch()
    env = dict(os.environ, HOME=str(home), PATH=f"{bin_dir}:{os.environ['PATH']}",
               BOOTSTRAP_LOG=str(log), KMONAD_PRIMARY=str(primary),
               KMONAD_SECONDARY=str(external))
    downloaded = root / "bootstrap.sh"
    shutil.copyfile(REPO / "bootstrap.sh", downloaded)
    for script, source in [(REPO / "bootstrap.sh", REPO),
                           (downloaded, home / ".local/share/chezmoi")]:
        log.unlink(missing_ok=True)
        subprocess.run(["bash", str(script)], env=env, check=True, capture_output=True)
        commands = [json.loads(line) for line in log.read_text().splitlines()]
        assert len(commands) == 2, commands
        init, apply = commands
        assert init[:3] == ["--source", str(source), "init"], init
        assert "https://github.com/AyMeeko/dotfiles.git" in init
        assert init[init.index("--branch") + 1] == "chezmoi-migration"
        assert "Machine role=omarchy" in init
        assert f"Internal keyboard device (/dev/input/by-id/ or by-path/)={primary}" in init
        assert f"External keyboard device (empty to omit)={external}" in init
        assert "Install dependencies and activate services=true" in init
        assert apply == ["--source", str(source), "apply", "--force"], apply
    log.unlink()
    env["KMONAD_PRIMARY"] = str(root / "missing")
    result = subprocess.run(["bash", str(downloaded)], env=env, capture_output=True)
    assert result.returncode != 0 and not log.exists()

    # Exercise the actual system setup with only package/privileged commands
    # replaced. Removing Krita from the package list must fail this check.
    config = root / "chezmoi.toml"
    config.write_text('[data]\nrole="omarchy"\nsetupEnabled=true\n'
                      'kmonadInternalDevice="/dev/input/test-keyboard"\n'
                      'kmonadExternalDevice=""\n')
    template = REPO / "home/run_onchange_before_10-system-setup.sh.tmpl"
    render_command = [shutil.which("chezmoi"), "--source", str(REPO), "--config", str(config),
                      "execute-template", "--file", str(template)]
    script = subprocess.check_output(render_command, env=env, text=True)
    installed = root / "krita-installed"
    for name, contents in {
        "pacman": '#!/bin/sh\nif [ "$*" = "-Q krita" ]; then test -e "$KRITA_INSTALLED"; fi\n',
        "sudo": "#!/bin/sh\nexit 1\n",
        "pkexec": '''#!/usr/bin/env python3
import json, os, pathlib, sys
with open(os.environ["BOOTSTRAP_LOG"], "a") as log:
    log.write(json.dumps(sys.argv[1:]) + "\\n")
if sys.argv[1:3] == ["/usr/bin/pacman", "-S"]:
    pathlib.Path(os.environ["KRITA_INSTALLED"]).touch()
''',
    }.items():
        path = bin_dir / name
        path.write_text(contents)
        path.chmod(0o755)
    env["KRITA_INSTALLED"] = str(installed)
    subprocess.run(["bash"], input=script, env=env, text=True, check=True, capture_output=True)
    commands = [json.loads(line) for line in log.read_text().splitlines()]
    assert ["/usr/bin/pacman", "-S", "--needed", "--noconfirm", "krita"] in commands, commands
    assert installed.exists()
    log.unlink()
    subprocess.run(["bash"], input=script, env=env, text=True, check=True, capture_output=True)
    commands = [json.loads(line) for line in log.read_text().splitlines()]
    assert not any(command[:2] == ["/usr/bin/pacman", "-S"] for command in commands), commands
    for overrides in ['{"setupEnabled":false}', '{"role":"wsl"}']:
        assert not subprocess.check_output(render_command + ["--override-data", overrides],
                                           env=env, text=True).strip()
print("PASS: bootstrap wiring, machine-local inputs, role guards and idempotent Krita installation")
