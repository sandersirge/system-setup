#!/usr/bin/env bash
# Install the CLI tools the zsh config uses, via Homebrew (no sudo):
#   zsh-autosuggestions, zsh-syntax-highlighting (not on Kali, which ships its own),
#   eza (ls replacement), grc (colorizer), bat (cat replacement)
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"
require_brew

pkgs=(grc bat)
command -v eza >/dev/null 2>&1 || pkgs+=(eza)
if [ "$(distro_id)" != kali ]; then
  pkgs+=(zsh-autosuggestions zsh-syntax-highlighting)
fi

say "brew install ${pkgs[*]}"
"$BREW" install --quiet "${pkgs[@]}"
say "done: eza $(eza --version | sed -n 2p | cut -d' ' -f1), bat $(bat --version | cut -d' ' -f2), grc installed"
