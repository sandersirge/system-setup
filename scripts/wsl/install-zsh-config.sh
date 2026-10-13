#!/usr/bin/env bash
# Install the Kali-based ~/.zshrc (Oh My Posh prompt) plus zsh-interactive-cd.
# Kali gets configs/wsl/zsh/zshrc.kali (plugins from /usr/share),
# every other distro gets configs/wsl/zsh/zshrc (plugins from Homebrew).
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"

src="$REPO_DIR/configs/wsl/zsh/zshrc"
[ "$(distro_id)" = kali ] && src="$REPO_DIR/configs/wsl/zsh/zshrc.kali"

# zsh-interactive-cd (cd <Tab> -> fzf folder picker)
zic="$HOME/.zsh/zsh-interactive-cd"
if [ -d "$zic/.git" ]; then
  git -C "$zic" pull -q
else
  mkdir -p "$HOME/.zsh"
  git clone -q --depth 1 https://github.com/changyuheng/zsh-interactive-cd.git "$zic"
fi
say "zsh-interactive-cd ready"

install_file "$src" "$HOME/.zshrc"
say "installed $(basename "$src") as ~/.zshrc"

command -v fzf >/dev/null 2>&1 || warn "fzf is missing: zsh-interactive-cd needs it (install it with your package manager)"
say "open a new tab or run: exec zsh"
