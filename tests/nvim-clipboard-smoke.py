"""Exercise real visual yanks and external pastes on the deployed Wayland config."""
import os
import subprocess
import tempfile

if not os.environ.get("WAYLAND_DISPLAY"):
    raise SystemExit("Run this in your local Wayland desktop after chezmoi apply.")


def run(*args, **kwargs):
    kwargs.setdefault("timeout", 15)
    if args[0] == "wl-copy":
        # wl-copy's background clipboard owner can retain inherited output pipes.
        return subprocess.run(args, check=True, stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL, **kwargs)
    if args[0] == "nvim":
        with tempfile.TemporaryFile() as output:
            try:
                return subprocess.run(args, check=True, stdout=output,
                                      stderr=subprocess.STDOUT, **kwargs)
            except subprocess.SubprocessError:
                output.seek(0)
                print(output.read().decode(errors="replace"))
                raise
    return subprocess.run(args, check=True, capture_output=True, **kwargs)


def nvim(lua, env):
    checked = ('local ok, err = pcall(function() ' + lua + ' end); '
               'if not ok then vim.api.nvim_err_writeln(tostring(err)); vim.cmd("cquit 1") end')
    run("nvim", "--headless", "+lua " + checked, "+qa!", env=env)


# Preserve clipboard contents (including a non-text MIME type) across the test.
types = subprocess.run(["wl-paste", "--list-types"], capture_output=True, text=True)
mime = None
previous = None
if types.returncode == 0 and types.stdout.strip():
    available = types.stdout.splitlines()
    mime = next((t for t in available if t.startswith("text/plain")), available[0])
    previous = run("wl-paste", "--no-newline", "--type", mime).stdout

try:
    for in_tmux in (False, True):
        env = dict(os.environ, DOTFILES_BOOTSTRAP="1")
        for key in ("SSH_TTY", "SSH_CONNECTION", "HERDR_PANE_ID", "TMUX"):
            env.pop(key, None)
        if in_tmux:
            env["TMUX"] = "/tmp/clipboard-test-no-server,1,0"
        for register in ("*", "+"):
            text = f"Neovim visual yank {register} tmux={in_tmux}"
            lua = (f'vim.api.nvim_buf_set_lines(0, 0, -1, false, {{"{text}"}}); '
                   f"vim.cmd('normal! ggV\"{register}y'); "
                   f'assert(vim.wait(3000, function() return vim.fn.system({{"wl-paste", '
                   f'"--no-newline"}}):gsub("\\n$", "") == "{text}" end, 50), '
                   '"Visual yank did not reach the system clipboard")')
            nvim(lua, env)
            check = run("wl-paste", "--no-newline").stdout.decode().rstrip("\n")
            assert check == text, "Clipboard disappeared when Neovim exited"

        run("wl-copy", "--type", "text/plain", input=b"Copied outside Neovim")
        lua = ('assert(vim.fn.getreg("*") == "Copied outside Neovim"); '
               'assert(vim.fn.getreg("+") == "Copied outside Neovim")')
        nvim(lua, env)
finally:
    if previous is not None:
        run("wl-copy", "--type", mime, input=previous)
    else:
        run("wl-copy", "--clear")

print("PASS: visual * / + yanks, external pastes, clipboard persistence, local and tmux")
