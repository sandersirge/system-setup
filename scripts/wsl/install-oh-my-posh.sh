#!/usr/bin/env bash
# Install Oh My Posh into ~/.local/bin (no sudo).
# Uses the official installer; falls back to the release binary when the installer
# can't run (e.g. Fedora's minimal image has no awk).
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"

if curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$LOCAL_BIN" >/tmp/omp-install.log 2>&1; then
  say "installed with the official installer"
else
  warn "official installer failed (see /tmp/omp-install.log), downloading the release binary instead"
  curl -fsSL https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o "$LOCAL_BIN/oh-my-posh"
  chmod +x "$LOCAL_BIN/oh-my-posh"
fi
say "oh-my-posh $("$LOCAL_BIN/oh-my-posh" --version)"
