# 08 — tmux + TPM plugins

> An advanced tmux + Neovim setup is planned in [16](16-tmux-neovim-advanced.md).

Config: [`configs/wsl/tmux/tmux.conf`](../configs/wsl/tmux/tmux.conf) → `~/.tmux.conf` (same in all six distros).

## Install

Needs `tmux`, `git`, `awk` (Fedora: `sudo dnf install -y gawk`), plus `fzf` and `python3` for
extrakto / tmux-fzf (all in the base scripts).

```bash
bash scripts/wsl/install-tmux.sh
```

Manual equivalent:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp configs/wsl/tmux/tmux.conf ~/.tmux.conf
tmux                      # then inside tmux: prefix + I  (capital i) installs plugins
```

Headless install (what the script does):

```bash
tmux new-session -d -s tpm_setup
tmux source-file ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins
tmux kill-session -t tpm_setup
```

## Plugins

| Plugin | What it does |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | sane defaults |
| [tmux-themepack](https://github.com/jimeh/tmux-themepack) | status bar theme (`powerline/default/cyan`) |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | save/restore sessions, windows, panes, folders |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | auto-save every 15 min, auto-restore on start (`@continuum-restore 'on'`) |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | copy mode → Windows clipboard (`clip.exe` on WSL) |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | `Ctrl+h/j/k/l` across panes and Vim splits |
| [tmux-open](https://github.com/tmux-plugins/tmux-open) | open selection (URL/file) with `o` |
| [extrakto](https://github.com/laktak/extrakto) | fuzzy-pick text from the screen |
| [tmux-fzf](https://github.com/sainnhe/tmux-fzf) | fzf menu for sessions/windows/panes/commands |
| [tmux-logging](https://github.com/tmux-plugins/tmux-logging) | log pane output / save history to a file |

Other settings: `set -g mouse on` (click panes, drag borders, scroll), and truecolor:

```tmux
set -as terminal-features ',xterm-256color:RGB'
```

Server-level options apply when the server starts → `tmux kill-server`, then start tmux again.

## Keys (prefix = `Ctrl+b`)

| Keys | Action |
|---|---|
| `prefix` `I` / `U` / `Alt+u` | install / update / remove plugins (TPM) |
| `prefix` `Ctrl+s` / `Ctrl+r` | save / restore session (resurrect) |
| `prefix` `[` → select → `y` | copy to Windows clipboard (yank) |
| `Ctrl+h/j/k/l` | move between panes |
| `prefix` `Ctrl+l` | clear the screen (plain `Ctrl+l` is taken by vim-tmux-navigator) |
| copy mode: select → `o` | open URL/file in Windows (tmux-open) |
| `prefix` `Tab` | extrakto |
| `prefix` `Shift+f` | tmux-fzf menu |
| `prefix` `Shift+p` | start/stop logging the pane |
| `prefix` `Alt+Shift+p` | save complete pane history |
| `prefix` `%` / `"` | split vertical / horizontal |
| `prefix` `c` / `n` / `p` / `d` | new window / next / previous / detach |

Reload the config inside tmux: `tmux source ~/.tmux.conf`.

## tmux-open on Arch / Fedora: `xdg-open` shim

tmux-open only looks for `xdg-open` (no override option), which Arch and Fedora don't have.
[`configs/wsl/bin/xdg-open`](../configs/wsl/bin/xdg-open) → `~/.local/bin/xdg-open` hands the
selection to Windows:

```sh
#!/bin/sh
case "$1" in
  *://*) exec explorer.exe "$1" ;;
  *)     exec explorer.exe "$(wslpath -w "$1")" ;;
esac
```

```bash
bash scripts/wsl/install-xdg-open-shim.sh
```
