#!/usr/bin/env bash
# Install logo-ls built from the Nerd Fonts v3 fork (UTFeight/logo-ls-modernized).
# The original Yash-Handa/logo-ls v1.3.7 uses icon codes removed in Nerd Fonts v3 (shows "?").
#
#   install-logo-ls.sh                 build with Go (installed via Homebrew) and install
#   install-logo-ls.sh /path/logo-ls   install an already-built binary (e.g. built in another distro)
#   install-logo-ls.sh --build-only OUT  build a static binary to OUT without installing
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"

build() {
  require_brew
  command -v go >/dev/null 2>&1 || "$BREW" install --quiet go
  local tmp; tmp=$(mktemp -d /tmp/logo-ls-build.XXXXXX)
  trap 'rm -rf -- "$tmp"' RETURN
  git clone -q --depth 1 https://github.com/utfeight/logo-ls-modernized.git "$tmp/src"
  ( cd "$tmp/src" && go mod tidy >/dev/null 2>&1 && CGO_ENABLED=0 go build -o logo-ls . )
  install -m 755 "$tmp/src/logo-ls" "$1"
  say "built static binary: $1"
}

case "${1:-}" in
  --build-only) build "${2:?output path required}"; exit 0 ;;
  "")           bin=$(mktemp /tmp/logo-ls.XXXXXX); build "$bin" ;;
  *)            bin="$1" ;;
esac

install -m 755 "$bin" "$LOCAL_BIN/logo-ls"
say "installed $LOCAL_BIN/logo-ls (alias: lls)"
