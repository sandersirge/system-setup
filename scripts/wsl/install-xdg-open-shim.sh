#!/usr/bin/env bash
# Add a minimal xdg-open to ~/.local/bin that hands URLs and files to Windows.
# Needed where xdg-open is missing (Arch, Fedora) so tmux-open's `o` key works.
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"

if command -v xdg-open >/dev/null 2>&1 && [ "$(command -v xdg-open)" != "$LOCAL_BIN/xdg-open" ]; then
  say "system xdg-open found at $(command -v xdg-open), nothing to do"
  exit 0
fi
install_file "$REPO_DIR/configs/wsl/bin/xdg-open" "$LOCAL_BIN/xdg-open" 755
say "installed $LOCAL_BIN/xdg-open"
