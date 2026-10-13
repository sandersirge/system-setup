# 05 — Homebrew in every distro

Homebrew on Linux (supported on WSL 2) is used for user-level tools that should be identical in
every distro: zsh plugins, `eza`, `bat`, `grc`, `go` (to build logo-ls). Each distro has its own
copy in `/home/linuxbrew/.linuxbrew`.

## 1. Prerequisites (sudo)

```bash
sudo apt-get update && sudo apt-get install -y build-essential procps curl file git      # Ubuntu, Debian, Kali
sudo pacman -S --needed base-devel procps-ng curl file git                               # Arch
sudo dnf group install -y development-tools && sudo dnf install -y procps-ng curl file git   # Fedora
```

## 2. Install (in every distro; asks for your sudo password + Enter)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

The installer ends with *"Warning: /home/linuxbrew/.linuxbrew/bin is not in your PATH"* and
"Next steps". That is expected — step 3 does it.

## 3. Add brew to zsh

Already in this repo's `.zshrc` files (above the Oh My Posh block):

```zsh
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
```

`eval "$(brew shellenv zsh)"` **prints nothing** — it only exports `PATH`, `HOMEBREW_PREFIX`,
etc. in the current shell. To see what it does, run it without `eval`:

```bash
brew shellenv zsh
```

## 4. Verify

```bash
brew --version          # Homebrew 7.x
which brew              # /home/linuxbrew/.linuxbrew/bin/brew
brew doctor
```

## Tips

- Disk: every distro has its own Homebrew and dependencies — six copies add up (`brew cleanup`).
- Arch: pacman + AUR already cover nearly everything; brew is mostly redundant there (kept here
  for identical plugin paths).
- brew's tools come first in `PATH`. Use brew for extra CLI tools; keep system packages
  (git, python, compilers) with apt/dnf/pacman.
- Update: `brew update && brew upgrade`.
