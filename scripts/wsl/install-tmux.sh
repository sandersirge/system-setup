#!/usr/bin/env bash
# Install ~/.tmux.conf, TPM and every plugin listed in it (tmux and git must be installed).
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"

command -v tmux >/dev/null 2>&1 || die "tmux is not installed"
command -v awk  >/dev/null 2>&1 || die "awk is missing (TPM needs it). Fedora: sudo dnf install -y gawk"

install_file "$REPO_DIR/configs/wsl/tmux/tmux.conf" "$HOME/.tmux.conf"

tpm="$HOME/.tmux/plugins/tpm"
[ -d "$tpm" ] || git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$tpm"

# TPM needs a running tmux server that has loaded the config
tmux new-session -d -s tpm_setup
tmux source-file "$HOME/.tmux.conf"
"$tpm/bin/install_plugins"
tmux kill-session -t tpm_setup

say "plugins: $(ls "$HOME/.tmux/plugins" | tr '\n' ' ')"
say "if tmux was already running: tmux kill-server, then start tmux again"
