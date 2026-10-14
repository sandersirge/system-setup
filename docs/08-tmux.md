# 08 — tmux + TPM plugins

Josean Martinez's tmux setup ([article](https://www.josean.com/posts/tmux-setup),
[his current `.tmux.conf`](https://github.com/josean-dev/dev-environment-files/blob/main/.tmux.conf))
plus extra plugins. Config: [`configs/wsl/tmux/tmux.conf`](../configs/wsl/tmux/tmux.conf) →
`~/.tmux.conf`, the same file in all six distros. Works together with Neovim ([16](16-tmux-neovim-advanced.md)).

## Install

Needs `tmux`, `git`, `awk` (Fedora: `sudo dnf install -y gawk`), plus `fzf` and `python3` for
extrakto / tmux-fzf (all in the base scripts), and the `tmux-256color` terminfo (present in all six
distros: `infocmp tmux-256color`).

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

After changing the config of a running tmux: `prefix r`. Prefix, terminal and theme changes need a
fresh server: `tmux kill-server`, then `tmux` again.

## Settings (from Josean's config)

| Setting | Effect |
|---|---|
| `prefix C-a` (unbind `C-b`) | prefix is **Ctrl+a**; press it twice to send Ctrl+a to the shell (start of line) |
| `default-terminal "tmux-256color"` + `terminal-features ',xterm-256color:RGB'` | correct keys/colors inside tmux, truecolor |
| `escape-time 10` | no delay when pressing `Esc` in Neovim inside tmux |
| `mode-keys vi`, `v` / `y` in copy mode, mouse drag doesn't leave copy mode | vi-style copy mode |
| `mouse on` | click panes, drag borders, scroll |
| `@resurrect-capture-pane-contents 'on'`, `@continuum-restore 'on'` | sessions incl. screen contents restored after a restart |

## Plugins

| Plugin | What it does |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | plugin manager |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | `Ctrl+h/j/k/l` across tmux panes **and** Neovim splits (Neovim side: [16](16-tmux-neovim-advanced.md)) |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | save/restore sessions, windows, panes, folders, pane contents |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | auto-save every 15 min, auto-restore on start |
| [tmux-tokyo-night](https://github.com/fabioluciano/tmux-tokyo-night) | status bar theme matching Neovim's tokyonight — loaded **last** (earlier breaks continuum's auto-save) |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | sane defaults *(extra)* |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | copy mode `y` → Windows clipboard (`clip.exe` on WSL) *(extra)* |
| [tmux-open](https://github.com/tmux-plugins/tmux-open) | open selection (URL/file) with `o` *(extra)* |
| [extrakto](https://github.com/laktak/extrakto) | fuzzy-pick text from the screen *(extra)* |
| [tmux-fzf](https://github.com/sainnhe/tmux-fzf) | fzf menu for sessions/windows/panes/commands *(extra)* |
| [tmux-logging](https://github.com/tmux-plugins/tmux-logging) | log pane output / save history to a file *(extra)* |

Previous theme, kept commented out in the config (swap the two `@plugin` lines to switch back):
`jimeh/tmux-themepack` with `@themepack 'powerline/default/cyan'`.

## Keys (prefix = `Ctrl+a`)

| Keys | Action |
|---|---|
| `prefix` `\|` / `prefix` `-` | split side by side / top and bottom |
| `Ctrl+h/j/k/l` | move between panes (and into / out of Neovim splits) |
| `prefix` `h/j/k/l` | resize the pane by 5 cells (repeat with the prefix) |
| `prefix` `m` | maximize / restore the pane |
| `prefix` `r` | reload `~/.tmux.conf` (the theme's version: also re-applies the theme, shows a message) |
| `prefix` `c` / `n` / `p` / `0-9` / `w` | new window / next / previous / by number / window list |
| `prefix` `d` | detach (`tmux a` re-attaches) |
| `prefix` `Alt+c` | make the current pane's folder the session's default folder |
| `prefix` `[` → `v` select → `y` | copy to the Windows clipboard (`q` leaves copy mode) |
| `prefix` `Ctrl+s` / `Ctrl+r` | save / restore session (resurrect) |
| `prefix` `I` / `U` / `Alt+u` | install / update / remove plugins (TPM) |
| `prefix` `Ctrl+l` | clear the screen (plain `Ctrl+l` is taken by vim-tmux-navigator) |
| copy mode: select → `o` | open URL/file in Windows (tmux-open) |
| `prefix` `Tab` | extrakto |
| `prefix` `Shift+f` | tmux-fzf menu |
| `prefix` `Shift+p` / `Alt+Shift+p` | start/stop logging the pane / save complete pane history |

## Verify

On an isolated server (own socket folder, doesn't touch running sessions):

```bash
export TMUX_TMPDIR=$(mktemp -d); tmux new-session -d; sleep 3
tmux show -gv prefix; tmux show -sv escape-time; tmux list-keys -T root | grep C-h
tmux kill-server
```

Expected: `C-a`, `10`, and `C-h` bound by vim-tmux-navigator.

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
