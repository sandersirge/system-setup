#!/usr/bin/env bash
# Fun terminal toys, fetch tools and extra CLI tools (docs/19-fun-and-cli-tools.md).
#   bash scripts/wsl/install-fun-tools.sh     # asks for the sudo password once (hollywood, apt)
# Installed in Ubuntu; works in the other distros too (hollywood only on Debian-based ones).
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"
require_brew

case "$(distro_id)" in
  ubuntu|debian|kali)
    say "apt: hollywood (fake hacker screen in tmux panes)"
    sudo apt-get install -y -qq hollywood ;;
  *) warn "hollywood is only packaged for Debian-based distros; skipping" ;;
esac

toys="genact cmatrix pipes-sh cbonsai asciiquarium sl cowsay fortune lolcat figlet"
fetch="fastfetch cpufetch"
tools="zoxide tlrc duf dust ncdu yazi glow lazydocker gping"
say "brew: $toys"
"$BREW" install --quiet $toys
say "brew: $fetch $tools"
"$BREW" install --quiet $fetch $tools
"$BREW" cleanup --prune=all -s >/dev/null 2>&1 || true

say "tldr pages cache"
tldr --update >/dev/null 2>&1 || true

v() { printf '  %-12s %s\n' "$1" "$(shift; "$@" 2>&1 | head -1 | cut -c1-60)"; }
say "installed (open a new terminal: zoxide + the fastfetch greeting come from ~/.zshrc):"
v hollywood sh -c 'command -v hollywood || echo missing'
v genact genact --version; v cmatrix sh -c 'command -v cmatrix'; v pipes.sh pipes.sh -v
v cbonsai sh -c 'command -v cbonsai'; v asciiquarium sh -c 'command -v asciiquarium'
v sl sh -c 'command -v sl'; v cowsay sh -c 'command -v cowsay'; v fortune sh -c 'command -v fortune'
v lolcat lolcat --version; v figlet figlet -v
v fastfetch fastfetch --version; v cpufetch cpufetch --version
v zoxide zoxide --version; v tldr tldr --version; v duf duf --version; v dust dust --version
v ncdu ncdu --version; v yazi yazi --version; v glow glow --version
v lazydocker lazydocker --version; v gping gping --version
