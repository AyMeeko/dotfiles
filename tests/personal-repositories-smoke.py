"""Exercise personal-repository setup in an isolated home with mocked tools."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]
MOCK = '''#!/usr/bin/env python3
import json, os, pathlib, sys
name = pathlib.Path(sys.argv[0]).name
root = pathlib.Path(os.environ["TEST_ROOT"])
with (root / "commands.jsonl").open("a") as log:
    log.write(json.dumps([name, *sys.argv[1:]]) + "\\n")
if name == "git":
    if sys.argv[1] == "clone":
        if "notes.git" in sys.argv[2] and (root / "fail-notes").exists():
            sys.exit(1)
        target = pathlib.Path(sys.argv[3])
        target.mkdir(parents=True)
        (target / ".git").mkdir()
        (target / ".git/origin").write_text(sys.argv[2])
        if target.name == "fonts":
            for filename, face in {"regular.ttf": "Regular", "bold.ttf": "Bold",
                                   "duplicate.otf": "Bold", "nested/italic.TTF": "Italic"}.items():
                font = target / filename
                font.parent.mkdir(parents=True, exist_ok=True)
                font.write_text(face)
            (target / "README.md").write_text("not a font")
    else:
        print((pathlib.Path(sys.argv[2]) / ".git/origin").read_text())
elif name == "fc-list":
    print("Regular")
    if (root / "cached").exists():
        print("Bold\\nItalic")
elif name == "fc-scan":
    print(pathlib.Path(sys.argv[-1]).read_text())
elif name == "fc-cache":
    if (root / "fail-cache").exists():
        sys.exit(1)
    (root / "cached").touch()
'''

with tempfile.TemporaryDirectory(prefix="dotfiles-personal-repos-") as directory:
    root = Path(directory)
    home = root / "home"
    home.mkdir()
    bin_dir = root / "bin"
    bin_dir.mkdir()
    for name in ["git", "fc-list", "fc-scan", "fc-cache"]:
        tool = bin_dir / name
        tool.write_text(MOCK)
        tool.chmod(0o755)
    config = root / "chezmoi.toml"
    config.write_text('[data]\nrole="omarchy"\nsetupEnabled=true\n')
    env = dict(os.environ, HOME=str(home), XDG_DATA_HOME=str(home / "data"),
               TEST_ROOT=str(root), PATH=f"{bin_dir}:{os.environ['PATH']}")
    script = subprocess.check_output([
        "chezmoi", "--source", str(REPO), "--config", str(config),
        "execute-template", "--file",
        str(REPO / "home/run_once_after_50-personal-repositories.sh.tmpl"),
    ], env=env, text=True)

    def run(success=True):
        result = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
        assert (result.returncode == 0) == success, result.stderr
        return result

    # A cache failure must be recoverable without overwriting copied fonts.
    (root / "fail-cache").touch()
    run(success=False)
    fonts = home / "data/fonts/aymeeko"
    assert {p.relative_to(fonts).as_posix() for p in fonts.rglob("*") if p.is_file()} == {
        "bold.ttf", "nested/italic.TTF"}
    (root / "fail-cache").unlink()
    # A private notes clone failure is retried, preserving the fonts checkout.
    (root / "fail-notes").touch()
    assert "1Password" in run(success=False).stderr
    (root / "fail-notes").unlink()
    run()
    notes = home / "notes"
    assert (notes / ".git").is_dir()
    (notes / "local-note.md").write_text("unsaved local work")
    (home / "src/fonts/README.md").write_text("local fonts edit")
    before = {p: p.stat().st_mtime_ns for p in fonts.rglob("*") if p.is_file()}
    run()
    assert before == {p: p.stat().st_mtime_ns for p in fonts.rglob("*") if p.is_file()}
    assert (notes / "local-note.md").read_text() == "unsaved local work"
    assert (home / "src/fonts/README.md").read_text() == "local fonts edit"
    commands = [json.loads(line) for line in (root / "commands.jsonl").read_text().splitlines()]
    assert sum(c[:2] == ["git", "clone"] and "fonts.git" in c[2] for c in commands) == 1
    assert not any(c[0] == "git" and "pull" in c for c in commands)
    assert (fonts / "bold.ttf").stat().st_mode & 0o777 == 0o644
    # Do not accept an unrelated directory at the notes destination.
    (notes / ".git/origin").unlink()
    (notes / ".git").rmdir()
    assert "not a Git checkout" in run(success=False).stderr
    assert (notes / "local-note.md").read_text() == "unsaved local work"
print("PASS: missing font faces, duplicate formats, cache/clone retries and local-work preservation")
