#!/usr/bin/env bash
# Shared helpers for the scripts in scripts/wsl. Source it, don't run it.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BREW=/home/linuxbrew/.linuxbrew/bin/brew
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:/home/linuxbrew/.linuxbrew/bin:$PATH"

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }

distro_id() { . /etc/os-release && echo "$ID"; }

require_brew() {
  [ -x "$BREW" ] || die "Homebrew not found at $BREW. Install it first (docs/05-homebrew.md)."
}

# Copy a file into place, keeping one timestamped backup of whatever was there before.
install_file() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
    cp "$dst" "$dst.bak.$(date +%Y%m%d-%H%M%S)"
    say "backed up existing $(basename "$dst")"
  fi
  install -m "${3:-644}" "$src" "$dst"
}
