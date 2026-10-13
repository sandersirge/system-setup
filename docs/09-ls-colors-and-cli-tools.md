# 09 — `ls` with icons (eza, logo-ls) and colorful output (grc, bat)

## Aliases (all six distros)

| Alias | Runs |
|---|---|
| `ls` | `eza --icons` |
| `ll` | `eza --icons -l --git` (long list + per-file git status) |
| `la` | `eza --icons -a` |
| `l` | `eza --icons` |
| `lls` | `logo-ls` (backup / alternative) |
| `cat` | `bat --paging=never` |
| `<cmd> --help` | output piped through `bat --language=help` |

The real commands: `command ls`, `command cat`, `command ping`, …

## eza

Maintained `ls` replacement with Nerd Fonts v3 icons and git status: <https://github.com/eza-community/eza>

```bash
brew install eza        # Arch/Fedora: already installed by the base scripts (pacman/dnf)
```

## logo-ls (Nerd Fonts v3 fixed build)

The original [Yash-Handa/logo-ls](https://github.com/Yash-Handa/logo-ls) (v1.3.7, 2021) uses icon
codes that Nerd Fonts v3 removed (e.g. `U+FB12`, `U+F755`) → `?` boxes. Some icons (git `U+E702`,
gear) still work because they weren't moved. Changing the font doesn't help.

Fix from [issue #49](https://github.com/Yash-Handa/logo-ls/issues/49): the fork
[UTFeight/logo-ls-modernized](https://github.com/UTFeight/logo-ls-modernized) (based on
[PR #46](https://github.com/Yash-Handa/logo-ls/pull/46)). It has no release binaries; its
`INSTALL` script clones, runs `go build`, and `sudo mv`s to `/usr/local/bin`. This repo does the
same without sudo, as a static binary:

```bash
bash scripts/wsl/install-logo-ls.sh                       # builds with Go from Homebrew, installs ~/.local/bin/logo-ls
bash scripts/wsl/install-logo-ls.sh --build-only /tmp/logo-ls   # build once...
bash scripts/wsl/install-logo-ls.sh /tmp/logo-ls          # ...install the same binary in other distros
```

Manual build:

```bash
brew install go
git clone --depth 1 https://github.com/utfeight/logo-ls-modernized.git
cd logo-ls-modernized && go mod tidy && CGO_ENABLED=0 go build -o logo-ls .
install -m 755 logo-ls ~/.local/bin/logo-ls
```

Notes: `logo-ls --version` still prints `v1.3.7` (the fork never bumped it). `logo-ls` doesn't
support `--color=auto`, `-C` or `-F`. Useful flags: `-a`, `-A`, `-l`, `-1`, `-D` (git status),
`-h`, `-t`, `-S`, `-R`. Go can be removed afterwards: `brew uninstall go`.

Alternative fix that keeps the original logo-ls: install the old **Symbols Nerd Font 2.3.3** on
Windows and add it as a fallback font (`"face": "JetBrainsMono Nerd Font, Symbols Nerd Font"`).

## grc — colors for ~80 commands

[grc](https://github.com/garabik/grc) (Generic Colouriser). Homebrew ships `etc/grc.zsh`, which
wraps each supported command in a function (only on a real terminal). Colored after setup:
`ping`, `df`, `du`, `free`, `ps`, `mount`, `lsblk`, `ss`, `netstat`, `dig`, `traceroute`,
`env`, `id`, `uptime`, `make`, `gcc`, … (32–41 commands depending on what each distro has).

Excluded on purpose (`unfunction` right after sourcing):

| Excluded | Why |
|---|---|
| `ls`, `diff`, `ip` | already colored (eza alias, `--color=auto` aliases) |
| `systemctl`, `journalctl` | grc would remove their own colors and the pager |
| `docker`, `docker-compose`, `docker-machine`, `kubectl` | would break `-it` sessions |
| `dnf`, `curl`, `mtr`, `php`, `tcpdump`, `lolcat` | prompts, progress bars, full-screen or REPL |

```zsh
if [ -f /home/linuxbrew/.linuxbrew/etc/grc.zsh ]; then
  source /home/linuxbrew/.linuxbrew/etc/grc.zsh
  for _c in ls diff ip curl systemctl journalctl dnf docker docker-compose docker-machine kubectl mtr php tcpdump lolcat; do
    (( $+functions[$_c] )) && unfunction $_c
  done
  unset _c
fi
```

## bat — `cat` with syntax highlighting, colored `--help`

[bat](https://github.com/sharkdp/bat). Installed from Homebrew so it is called `bat` everywhere
(Debian/Ubuntu's apt package names it `batcat`).

```zsh
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain --paging=never'
fi
```

When piped (`cat file | grep x`), bat behaves like plain `cat`. The `--help` global alias only
covers `--help`, not `-h`.

## Already colored without extra tools

`grep`/`diff`/`ip` (`--color=auto` aliases), man pages (`LESS_TERMCAP_*`), completion lists
(`LS_COLORS`), command line (zsh-syntax-highlighting), `git`, `tree`, `htop`, `systemctl`.

## Install everything

```bash
bash scripts/wsl/install-cli-tools.sh   # eza grc bat (+ zsh plugins) via brew
bash scripts/wsl/install-logo-ls.sh
exec zsh
```
