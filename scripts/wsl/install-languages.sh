#!/usr/bin/env bash
# Install language SDKs and runtimes in this WSL distro (docs/17-languages.md).
#   bash scripts/wsl/install-languages.sh              # everything (asks for the sudo password once)
#   bash scripts/wsl/install-languages.sh --no-system  # skip the distro packages (C/C++, build deps)
# Which tool installs what:
#   distro packages : C/C++ (gcc, clang, gdb, lldb, ninja, valgrind), cpanminus, build libraries
#   mise            : node (LTS), python, go, java (Temurin 25), kotlin, maven, gradle, zig
#   Homebrew        : erlang, rebar3, elixir, gleam, lua, luarocks, ruby, php, composer
#   own installers  : rustup (Rust), ghcup (Haskell), dotnet-install (.NET LTS), uv (Python tools)
#   npm (global)    : firebase-tools. Next.js / React are created per project with npx (see docs/17).
# Prerequisites: Homebrew (docs/05). Re-running is safe: it installs only what's missing / upgrades.
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"
require_brew
export PATH="$HOME/.cargo/bin:$HOME/.ghcup/bin:$HOME/.dotnet:$PATH"

# --- 1. distro packages (sudo) ------------------------------------------------------------
if [ "${1:-}" != "--no-system" ]; then
  say "distro packages: C/C++ toolchain, cpanminus, build libraries (sudo)"
  case "$(distro_id)" in
    ubuntu|debian|kali)
      sudo apt-get update -qq
      sudo apt-get install -y -qq build-essential clang clangd clang-format lldb gdb ninja-build \
        pkg-config valgrind cpanminus libgmp-dev libffi-dev libncurses-dev zlib1g-dev libicu-dev ;;
    fedora)
      sudo dnf install -y -q gcc gcc-c++ clang clang-tools-extra lldb gdb ninja-build pkgconf-pkg-config \
        valgrind perl-App-cpanminus gmp-devel libffi-devel ncurses-devel zlib-devel libicu ;;
    arch)
      sudo pacman -S --needed --noconfirm base-devel clang lldb gdb ninja valgrind cpanminus \
        gmp libffi ncurses zlib icu ;;
    *) warn "unknown distro $(distro_id): install a C/C++ toolchain yourself" ;;
  esac
fi

# --- 2. Homebrew: BEAM languages, Lua, Ruby, PHP --------------------------------------------
say "brew: mise erlang rebar3 elixir gleam lua luarocks ruby php composer"
"$BREW" install --quiet mise erlang rebar3 elixir gleam lua luarocks ruby php composer
# erlang pulls in brew's llvm (via mesa); unlink it so the distro's clang/clangd stay first on PATH
"$BREW" unlink llvm >/dev/null 2>&1 || true

# --- 3. mise: Node, Python, Go, JVM, Zig (prebuilt downloads, global defaults) ---------------
say "mise: node python go java kotlin maven gradle zig (global)"
MISE="$("$BREW" --prefix)/bin/mise"
"$MISE" use -g --yes node@lts python@latest go@latest java@temurin-25 \
  kotlin@latest maven@latest gradle@latest zig@latest
eval "$("$MISE" env -s bash)"   # put them on PATH for the rest of this script

say "npm -g: firebase-tools"
npm install -g --silent firebase-tools >/dev/null

# --- 4. per-language installers --------------------------------------------------------------
if ! command -v rustup >/dev/null 2>&1; then
  say "rustup (Rust)"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null
  . "$HOME/.cargo/env"
fi
rustup component add rust-analyzer rust-src rustfmt clippy >/dev/null 2>&1

if ! command -v uv >/dev/null 2>&1; then
  say "uv (Python package / tool manager)"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh >/dev/null 2>&1
fi

if ! command -v ghcup >/dev/null 2>&1; then
  say "ghcup: GHC + cabal + stack (Haskell; large download, takes a while)"
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org |
    env BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_INSTALL_STACK=1 sh >/dev/null 2>&1
fi
# finish an interrupted ghcup install
for t in ghc cabal stack; do
  command -v "$t" >/dev/null 2>&1 || { say "ghcup: $t"; ghcup install "$t" --set recommended >/dev/null; }
done

if [ ! -x "$HOME/.dotnet/dotnet" ]; then
  say ".NET SDK (LTS) -> ~/.dotnet"
  tmp=$(mktemp -d)
  curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$tmp/dotnet-install.sh"
  bash "$tmp/dotnet-install.sh" --channel LTS --install-dir "$HOME/.dotnet" >/dev/null
  rm -rf -- "$tmp"
fi

# --- 5. clean download caches (~2 GB) -------------------------------------------------------
say "cleaning download caches (brew, mise, ghcup)"
"$BREW" cleanup --prune=all -s >/dev/null 2>&1 || true
"$MISE" cache clear >/dev/null 2>&1 || true
ghcup gc --cache --tmpdirs >/dev/null 2>&1 || true

# --- 6. summary -------------------------------------------------------------------------------
v() { printf '  %-10s %s\n' "$1" "$(shift; "$@" 2>&1 | head -1 | cut -c1-70)"; }
say "installed (open a new shell so ~/.zshrc picks up mise, cargo, ghcup, dotnet):"
v gcc gcc -dumpfullversion; v clang clang --version; v gdb gdb --version
v node node --version; v npm npm --version; v firebase firebase --version
v python python --version; v uv uv --version; v go go version
v java java --version; v kotlin kotlin -version; v maven mvn --version; v gradle sh -c "gradle --version | grep -m1 '^Gradle'"
v zig zig version; v rust rustc --version; v haskell ghc --version; v cabal cabal --version
v stack stack --version; v dotnet dotnet --version; v erlang erl -noshell -eval 'io:format("OTP ~s",[erlang:system_info(otp_release)]),halt().'
v elixir elixir --short-version; v gleam gleam --version; v lua lua -v; v luarocks luarocks --version
v ruby ruby --version; v php php --version; v composer composer --version; v perl perl -e 'print "perl $^V"'
v cpanm cpanm --version
