#!/usr/bin/env bash
# Run every user-level setup step for one distro, in order (no sudo needed).
#
# Prerequisites (need sudo, see docs/03 - docs/05):
#   1. base packages:   scripts/wsl/base-packages/<distro>.sh
#   2. zsh as login shell:   chsh -s /usr/bin/zsh
#   3. Homebrew installed at /home/linuxbrew/.linuxbrew
#
# Usage:  bash scripts/wsl/bootstrap.sh [--with-neovim] [/path/to/prebuilt/logo-ls]
#   --with-neovim   also run install-neovim.sh (Neovim + tools, config link, plugins, parsers, Mason)
set -Eeuo pipefail
here="$(dirname "$0")"
. "$here/lib.sh"

with_neovim=0
if [ "${1:-}" = "--with-neovim" ]; then with_neovim=1; shift; fi

[ "$(basename "$(getent passwd "$(id -un)" | cut -d: -f7)")" = zsh ] || warn "login shell is not zsh yet: chsh -s /usr/bin/zsh"
require_brew

steps=(install-oh-my-posh.sh install-cli-tools.sh install-zsh-config.sh install-tmux.sh install-xdg-open-shim.sh)
for s in "${steps[@]}"; do
  say "---- $s"
  bash "$here/$s"
done

say "---- install-logo-ls.sh"
bash "$here/install-logo-ls.sh" ${1:+"$1"}

if [ "$with_neovim" = 1 ]; then
  say "---- install-neovim.sh"
  bash "$here/install-neovim.sh"
fi

say "all done in $WSL_DISTRO_NAME -> exec zsh"
