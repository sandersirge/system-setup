# 19 — Fun commands, fetch tools and extra CLI tools

Terminal toys, system-info "fetch" tools and a few useful extras. Installed in **Ubuntu**; the
script works in the other distros too (hollywood only on Debian-based ones).

```bash
bash scripts/wsl/install-fun-tools.sh      # asks for the sudo password once (hollywood via apt)
```

Script: [`scripts/wsl/install-fun-tools.sh`](../scripts/wsl/install-fun-tools.sh). Everything
except hollywood comes from Homebrew. The zshrc ([04](04-zsh.md)) sets up zoxide, the `y` function
for yazi and the fastfetch greeting. Each of those lines only runs if the tool is installed.

## Fun

| Command | What it does | Quit |
|---|---|---|
| `hollywood` | splits the terminal (tmux/byobu) into panes of scrolling fake "hacker" activity | `Ctrl+c`, then `exit` / `tmux kill-session` |
| `genact` | fake activity: compiling, downloading, crypto mining, `genact -m cargo` for one module, `genact -l` lists them | `Ctrl+c` |
| `cmatrix` | Matrix digital rain. `cmatrix -C cyan`, `-r` rainbow, `-s` screensaver mode | `q` |
| `pipes.sh` | animated pipes screensaver. `pipes.sh -t 1` other pipe style, `-p 5` more pipes | `q` / `Ctrl+c` |
| `cbonsai -l` | grows an animated bonsai tree (`-l` live). `cbonsai -i -l` infinite | `q` |
| `asciiquarium` | ASCII aquarium with fish, sharks and a submarine | `q` |
| `sl` | steam locomotive for when you type `sl` instead of `ls`. `sl -F` flies | waits until it passes |
| `cowsay hi` / `cowsay -f tux hi` | talking cow / other characters (`cowsay -l`) | — |
| `fortune` | random quote or joke | — |
| `lolcat` | rainbow colors for any output | — |
| `figlet Sander` | big ASCII letters. `figlet -f slant Hi`, fonts: `figlist` | — |

Combinations:

```bash
fortune | cowsay | lolcat
figlet -f slant system-setup | lolcat
genact -m cc -s 2               # compile something "important", 2x speed
```

## Fetch

| Command | What it shows |
|---|---|
| `fastfetch` | distro logo + OS, kernel, CPU, GPU, RAM, disks, shell, terminal, theme |
| `cpufetch` | big AMD/Ryzen logo with cores, threads, caches, frequency |

`fastfetch` runs automatically in a **new terminal** (Windows Terminal / WezTerm tab). It doesn't
run in tmux panes or the Neovim terminal, where it would repeat in every pane. To turn the greeting
off, delete the `fastfetch` lines at the end of `~/.zshrc`. Other layouts:
`fastfetch --list-presets`, then `fastfetch -c <preset>`.

In WSL, fastfetch shows the WSL kernel and the Windows GPU through the WSL driver, and "Host"
says it's running under WSL. That's expected.

## Useful extras

| Command | What it does | Example |
|---|---|---|
| `z` ([zoxide](https://github.com/ajeetdsouza/zoxide)) | jumps to the most-used folder matching what you type | `z nvim` → `~/…/configs/nvim`; `zi` = fzf picker |
| `tldr` ([tlrc](https://github.com/tldr-pages/tlrc)) | short example-based man pages | `tldr tar`, `tldr git rebase` |
| `duf` | disk usage per drive, as a table (better `df`) | `duf` |
| `dust` | which folders take the most space (better `du`) | `dust ~`, `dust -d 2 /` |
| `ncdu` | interactive disk-usage browser: arrows to move, `d` deletes (asks first) | `ncdu ~` |
| `y` ([yazi](https://yazi-rs.github.io)) | terminal file manager with previews; quitting with `q` leaves you in that folder | `y`, `?` for keys |
| `glow` | renders Markdown in the terminal | `glow docs/19-fun-and-cli-tools.md`, `glow` alone browses |
| `lazydocker` | Docker TUI: containers, logs, images, stats (like lazygit) | needs Docker Desktop's WSL integration ([11](11-docker.md)) |
| `gping` | ping with a live graph; several hosts at once | `gping 1.1.1.1 google.com` |

zoxide learns from the folders you visit with `cd`, so `z` gets better after a few days. To look
inside the Windows drives, `ncdu /mnt/c/Users` works too, but it's slow over `/mnt/c`.

## Updating

```bash
brew upgrade              # everything except hollywood
sudo apt upgrade          # hollywood
tldr --update             # tldr pages
```

Back to the [README](../README.md).
