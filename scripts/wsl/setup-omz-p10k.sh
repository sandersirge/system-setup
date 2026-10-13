#!/usr/bin/env bash
# Switch this distro from Oh My Posh to Oh My Zsh + Powerlevel10k (what Fedora uses).
#
#   setup-omz-p10k.sh            install, then run the p10k wizard yourself on the next zsh start
#   setup-omz-p10k.sh --my-p10k  also install configs/wsl/p10k/p10k.zsh (rainbow style, fixed icons)
#
# Roll back: cp ~/.zshrc.pre-oh-my-zsh ~/.zshrc && exec zsh   (uninstall fully: uninstall_oh_my_zsh)
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"

[ -d "$HOME/.oh-my-zsh" ] || {
  say "installing Oh My Zsh (unattended)"
  # --keep-zshrc: we install our own .zshrc below; save the current one for rollback first
  [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.pre-oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}

C="$HOME/.oh-my-zsh/custom"
clone() { [ -d "$2" ] || git clone -q --depth 1 "$1" "$2"; }
clone https://github.com/romkatv/powerlevel10k.git              "$C/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions          "$C/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting      "$C/plugins/zsh-syntax-highlighting"
say "powerlevel10k + plugins ready"

install_file "$REPO_DIR/configs/wsl/zsh/zshrc.fedora-omz-p10k" "$HOME/.zshrc"
[ "${1:-}" = --my-p10k ] && install_file "$REPO_DIR/configs/wsl/p10k/p10k.zsh" "$HOME/.p10k.zsh"

say "run: exec zsh   (without ~/.p10k.zsh the configuration wizard starts; answer No to installing Meslo)"
