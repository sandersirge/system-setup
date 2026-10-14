# 04 — zsh in every distro (Kali's config everywhere)

## 1. Install zsh

```bash
sudo apt update && sudo apt install -y zsh          # Ubuntu, Ubuntu-26.04, Debian, Kali
sudo pacman -S --needed zsh                         # Arch
sudo dnf install -y zsh util-linux-user             # Fedora (util-linux-user = chsh)
```

(The base scripts in [03](03-base-packages.md) already install it.)

## 2. Make zsh the login shell

```bash
chsh -s /usr/bin/zsh
```

Always pass **`/usr/bin/zsh`**, not `"$(command -v zsh)"`. On Arch and Fedora `/usr/sbin` and
`/usr/bin` are the same folder and `command -v zsh` can return `/usr/sbin/zsh`, which is not in
`/etc/shells`:

```text
chsh: "/usr/sbin/zsh" is not listed in /etc/shells.
```

Check the allowed shells with `chsh -l` (or `cat /etc/shells`).

Avoid zsh's first-run menu (`zsh-newuser-install`) by having a `~/.zshrc`: `touch ~/.zshrc`.

Verify (new tab): `echo $SHELL` → `/usr/bin/zsh`. From Windows for all distros:

```powershell
foreach ($d in 'Ubuntu','Ubuntu-26.04','Debian','kali-linux','archlinux','FedoraLinux-44') {
  "$d : " + (wsl -d $d --cd / -e sh -c 'getent passwd "$(id -un)" | cut -d: -f7')
}
```

## 3. The `.zshrc` (Kali's, shared by all distros)

Every Oh My Posh distro uses Kali Linux's default `.zshrc` with additions appended:

| File | Used on | Difference |
|---|---|---|
| [`configs/wsl/zsh/zshrc`](../configs/wsl/zsh/zshrc) | Ubuntu, Ubuntu-26.04, Debian, Arch | plugins loaded from Homebrew (`/home/linuxbrew/.linuxbrew/share/...`) |
| [`configs/wsl/zsh/zshrc.kali`](../configs/wsl/zsh/zshrc.kali) | kali-linux | plugins from `/usr/share/...` (Kali packages) |
| [`configs/wsl/zsh/zshrc.fedora-omz-p10k`](../configs/wsl/zsh/zshrc.fedora-omz-p10k) | FedoraLinux-44 | Oh My Zsh + Powerlevel10k ([07](07-oh-my-zsh-powerlevel10k.md)) |

Install (after Homebrew, [05](05-homebrew.md)):

```bash
bash scripts/wsl/install-cli-tools.sh     # brew: zsh-autosuggestions, zsh-syntax-highlighting, eza, grc, bat
bash scripts/wsl/install-zsh-config.sh    # ~/.zshrc (+ zsh-interactive-cd)
exec zsh
```

What the Kali base gives you:

- history settings (`HISTSIZE`, dedupe, `hist_verify`), `history` shows all entries
- menu completion with colors, case-insensitive matching
- emacs key bindings + Ctrl/Home/End/PageUp keys, `Shift+Tab` undo
- `setopt autocd` (type a folder name to `cd` into it)
- colored `grep`, `diff`, `ip`, colored man pages (`LESS_TERMCAP_*`)
- Kali's own two-line prompt + `Ctrl+P` toggle — **overridden** by Oh My Posh, which loads later

Appended sections, in order:

```zsh
# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Oh My Posh
export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init zsh --config /mnt/c/Users/<you>/AppData/Local/Programs/oh-my-posh/themes/maxed_pc.omp.json)"

# Truecolor (TERM is set by WSL/tmux, do not hard-code it)
export COLORTERM=24bit

# zsh-interactive-cd
[ -f ~/.zsh/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh ] && source ~/.zsh/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh

# grc / bat colors + eza / logo-ls aliases   -> see docs/09
```

The theme is read straight from the Windows themes folder, so one theme file serves PowerShell,
cmd, Git Bash and all WSL distros.

## 4. Plugins

| Plugin | What it does | Source |
|---|---|---|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | grey suggestion from history while typing, `→` accepts | Homebrew (Kali: apt) |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | command green if it exists, red if not | Homebrew (Kali: apt) |
| [zsh-interactive-cd](https://github.com/changyuheng/zsh-interactive-cd) | `cd <Tab>` opens an fzf folder picker (needs `fzf`) | `git clone` → `~/.zsh/zsh-interactive-cd` |

Check that they load in every distro:

```bash
zsh -ic 'echo "as=${ZSH_AUTOSUGGEST_STRATEGY:+yes} hl=${ZSH_HIGHLIGHT_VERSION:-no} zic=$(( $+functions[zic-completion] ))"'
```

## 5. TERM and COLORTERM

- `TERM=xterm-256color` is set by WSL automatically (and by tmux inside tmux). **Never hard-code
  TERM in `.zshrc`** — it would override tmux's value and break rendering in panes.
- `COLORTERM=24bit` is not set by default → exported in `.zshrc` so tools use truecolor.
- tmux side: `set -as terminal-features ',xterm-256color:RGB'` in `.tmux.conf` ([08](08-tmux.md)).

## 5b. Broken completion links (Docker Desktop `_docker`)

Docker Desktop's WSL integration symlinks `/usr/share/zsh/vendor-completions/_docker` to
`/mnt/wsl/docker-desktop/cli-tools/...`. That target only exists in distros where the integration
is currently active — elsewhere the link dangles and every new shell / tmux pane prints:

```text
compinit:527: no such file or directory: /usr/share/zsh/vendor-completions/_docker
```

Deleting the link doesn't stick (Docker Desktop recreates it). All `.zshrc` variants contain a block
right before `compinit` (before `source $ZSH/oh-my-zsh.sh` on Fedora) that, **only if a broken link
exists**, swaps that folder in `fpath` for `~/.cache/zsh-vendor-completions` — a copy with only the
working files. zsh's own `_docker` completion still works.

Check which distros have the dangling link:

```bash
find /usr/share/zsh/vendor-completions -xtype l
```

## 6. After editing

Existing tabs keep the old shell. Reload with `exec zsh` (or open a new tab). Symptom of a stale
tab: things work inside tmux (new shells) but not in the plain tab. Check with `whence -w ping`
(`function` = new config loaded, `command` = old shell).
