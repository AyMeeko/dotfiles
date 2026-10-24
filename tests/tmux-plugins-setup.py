"""Test plugin bootstrap with mocked Git; preserve checkouts and machine-local saves."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]
MOCK = '''#!/usr/bin/env python3
import json,os,pathlib,sys
root = pathlib.Path(os.environ["TEST_ROOT"])
with (root / "git.jsonl").open("a") as log:
    log.write(json.dumps(sys.argv[1:]) + "\\n")
if (root / "fail-git").exists():
    sys.exit(1)
if sys.argv[1] == "clone":
    repo = sys.argv[-2].rsplit("/", 1)[-1].removesuffix(".git")
    target = pathlib.Path(sys.argv[-1])
    target.mkdir(parents=True)
    (target / ".git").mkdir()
    entry = {"tpm": "tpm", "tmux-resurrect": "resurrect.tmux", "tmux-continuum": "continuum.tmux"}[repo]
    (target / entry).write_text("#!/bin/sh\\nexit 0\\n")
'''

with tempfile.TemporaryDirectory(prefix="tmux-plugin-setup-", dir="/tmp/opencode") as directory:
    root = Path(directory)
    home = root / "home"
    home.mkdir()
    tools = root / "bin"
    tools.mkdir()
    git = tools / "git"
    git.write_text(MOCK)
    git.chmod(0o755)
    env = dict(os.environ, HOME=str(home), TEST_ROOT=str(root), PATH=f"{tools}:{os.environ['PATH']}")
    config = root / "chezmoi.toml"

    def render(role="omarchy", enabled=True):
        config.write_text(f'[data]\nrole="{role}"\nsetupEnabled={str(enabled).lower()}\n')
        return subprocess.check_output([
            "chezmoi", "--source", str(REPO), "--config", str(config), "execute-template", "--file",
            str(REPO / "home/run_once_after_23-tmux-plugins.sh.tmpl"),
        ], env=env, text=True)

    assert not render(enabled=False).strip()
    assert not render(role="wsl").strip()
    script = render()
    base = home / ".tmux/plugins"
    snapshot = home / ".local/share/tmux/resurrect/last"
    snapshot.parent.mkdir(parents=True)
    snapshot.write_text("existing session snapshot")

    def run(ok=True):
        result = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
        assert (result.returncode == 0) == ok, result.stderr
        assert not list(base.glob(".install-*")), "staging directory leaked"
        assert snapshot.read_text() == "existing session snapshot"

    (root / "fail-git").touch()
    run(ok=False)
    assert not (base / "tpm").exists(), "failed clone published"
    (root / "fail-git").unlink()
    # An unrelated/incomplete path is a conflict, not permission to delete it.
    (base / "tpm").mkdir()
    keep = base / "tpm/keep"
    keep.write_text("user work")
    run(ok=False)
    assert keep.read_text() == "user work"
    keep.unlink()
    (base / "tpm").rmdir()
    (root / "git.jsonl").unlink(missing_ok=True)
    run()
    commands = [json.loads(line) for line in (root / "git.jsonl").read_text().splitlines()]
    assert len([c for c in commands if c[0] == "clone"]) == 3, commands
    assert len([c for c in commands if "checkout" in c and "--detach" in c]) == 3, commands
    for name, entry in [("tpm", "tpm"), ("tmux-resurrect", "resurrect.tmux"), ("tmux-continuum", "continuum.tmux")]:
        target = base / name / entry
        assert target.is_file()
        target.write_text("local plugin edit")
    (root / "git.jsonl").unlink()
    run()
    assert not (root / "git.jsonl").exists(), "repeat bootstrap changed existing clones"
    assert all((base / name / entry).read_text() == "local plugin edit" for name, entry in
               [("tpm", "tpm"), ("tmux-resurrect", "resurrect.tmux"), ("tmux-continuum", "continuum.tmux")])
print("PASS: guarded plugin setup, staged failure recovery, conflicts, checkouts and snapshot preservation")
