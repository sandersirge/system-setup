#!/usr/bin/env bash
# Install Neovim + everything the config needs in this WSL distro (no sudo), link the config
# from the repo, then install plugins, treesitter parsers and Mason packages headless.
#   bash scripts/wsl/install-neovim.sh
# Prerequisites: Homebrew (docs/05), base packages (build tools, node, python, java - docs/03).
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"
require_brew
export PATH="$HOME/.cargo/bin:$PATH"

say "brew: neovim ripgrep fd lazygit tree-sitter-cli"
"$BREW" install --quiet neovim ripgrep fd lazygit tree-sitter-cli

if ! command -v rustup >/dev/null 2>&1; then
  say "rustup (Rust toolchain: rust-analyzer, rustfmt)"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null
  . "$HOME/.cargo/env"
fi
rustup component add rust-analyzer rust-src rustfmt clippy >/dev/null 2>&1
say "rust $(rustc --version | cut -d' ' -f2), rust-analyzer $(rust-analyzer --version | cut -d' ' -f2)"

if [ ! -x "$LOCAL_BIN/win32yank.exe" ]; then
  say "win32yank (WSL <-> Windows clipboard)"
  tmp=$(mktemp -d)
  curl -fsSL https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip -o "$tmp/w.zip"
  unzip -q -o "$tmp/w.zip" -d "$tmp"
  install -m 755 "$tmp/win32yank.exe" "$LOCAL_BIN/win32yank.exe"
  rm -rf -- "$tmp"
fi

# ~/.config/nvim -> repo (keep one backup of a real folder that's in the way)
target="$REPO_DIR/configs/nvim"
mkdir -p "$HOME/.config"
if [ -L "$HOME/.config/nvim" ]; then
  ln -sfn "$target" "$HOME/.config/nvim"
elif [ -e "$HOME/.config/nvim" ]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d-%H%M%S)"
  ln -s "$target" "$HOME/.config/nvim"
  warn "existing ~/.config/nvim moved to ~/.config/nvim.bak.*"
else
  ln -s "$target" "$HOME/.config/nvim"
fi
say "~/.config/nvim -> $target"

say "plugins (lazy.nvim)"
nvim --headless "+Lazy! sync" "+qa!" >/dev/null 2>&1
say "treesitter parsers + Mason packages (first run takes a few minutes)"
nvim --headless -c "luafile $REPO_DIR/scripts/nvim/bootstrap.lua" 2>&1 | grep -v '^\['
say "done -> start nvim; :checkhealth vim.lsp / nvim-treesitter / mason"
