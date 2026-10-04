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
print("PASS: local/downloaded bootstrap, machine-local inputs and missing-device guard")
