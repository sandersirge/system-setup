# 17 — Language SDKs and runtimes (WSL)

Compilers, runtimes and SDKs for the main languages, installed in **Ubuntu** and **Fedora**. The
other four distros stay lean to save disk space: the full set is about 8–10 GB per distro, and
all the WSL disks live on `C:`. The same script works there too if needed.

```bash
bash scripts/wsl/install-languages.sh              # asks for the sudo password once
bash scripts/wsl/install-languages.sh --no-system  # skip distro packages (C/C++, build libraries)
```

Script: [`scripts/wsl/install-languages.sh`](../scripts/wsl/install-languages.sh). It's safe to
re-run, because it only installs what's missing. Open a new shell afterwards.

## Which tool installs what

Each language gets one tool, so there's only one active version of each on `PATH`:

| Tool | Languages | Why this tool |
|---|---|---|
| distro packages (`apt` / `dnf` / `pacman`) | C, C++ (gcc, g++, clang, clangd, clang-format, gdb, lldb, ninja, valgrind), Perl's `cpanm` | compilers and debuggers belong to the system. Perl itself is already part of every distro |
| [mise](https://mise.jdx.dev) | Node.js (LTS), Python, Go, Java (Temurin 25), Kotlin, Maven, Gradle, Zig | one version manager for many languages, using prebuilt downloads. Versions can be set per project |
| Homebrew | Erlang + rebar3, Elixir, Gleam, Lua + LuaRocks, Ruby, PHP + Composer | prebuilt packages. mise would compile these from source, which is slow and needs many build libraries |
| [rustup](https://rustup.rs) | Rust (+ rust-analyzer, rustfmt, clippy) | the official Rust installer |
| [ghcup](https://www.haskell.org/ghcup/) | Haskell: GHC, cabal, stack | the official Haskell installer |
| [dotnet-install](https://learn.microsoft.com/dotnet/core/tools/dotnet-install-script) | .NET SDK (LTS) → `~/.dotnet` | Microsoft's script. It doesn't need a package repository |
| [uv](https://docs.astral.sh/uv/) | Python packages, virtual environments, CLI tools | much faster than pip, and keeps tools out of the system Python |
| npm (global) | `firebase` (firebase-tools) | Firebase's own CLI |

## Shell setup

The zshrc ([04](04-zsh.md)) loads the managers after Homebrew. mise comes **last** so its versions
win over brew's and the distro's (for example Python 3.15 from brew, or `nodejs` from apt):

```zsh
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"
if [ -d "$HOME/.dotnet" ]; then
  export DOTNET_ROOT="$HOME/.dotnet" DOTNET_CLI_TELEMETRY_OPTOUT=1
  export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
fi
(( $+commands[mise] )) && eval "$(mise activate zsh)"
```

Every line checks first that the tool is installed, so the same zshrc works in the distros that
don't have them.

## Versions with mise

```bash
mise ls                          # what's installed / active
mise use -g node@lts             # change the global default
mise use node@20 python@3.12     # this project only (writes mise.toml in the folder)
mise ls-remote java | grep temurin
mise upgrade                     # newer versions within the requested ranges
```

A project with `.nvmrc`, `.python-version`, `.tool-versions` or `mise.toml` switches versions
automatically when you `cd` into it.

## JavaScript frameworks: Next.js, React

These are npm packages added to each project, not runtimes, so nothing is installed globally.
Create a project with:

```bash
npx create-next-app@latest my-app          # Next.js (React included)
npm create vite@latest my-app -- --template react-ts   # plain React + TypeScript (Vite)
```

Firebase: `firebase login --no-localhost` (WSL has no browser of its own), then `firebase init`
inside the project.

## Per-language notes

| Language | Try it | Packages |
|---|---|---|
| C / C++ | `gcc hello.c -o hello`, `clang++ -std=c++23 main.cpp` | system `-dev` packages, CMake + Ninja |
| Python | `python`, `uv venv && uv pip install requests` | `uv tool install ruff` for CLI tools |
| Node | `node`, `npm init -y` | `npm`, `npx` |
| Go | `go mod init example.com/x && go run .` | `go install pkg@latest` → `~/go/bin` |
| Rust | `cargo new x && cargo run` | `cargo add`, `cargo install` |
| Java / Kotlin | `java Main.java`, `kotlinc hello.kt -include-runtime -d hello.jar` | Maven `mvn`, Gradle `gradle init` |
| Erlang / Elixir / Gleam | `erl`, `iex`, `gleam new x` | `rebar3`, `mix`, `gleam add` |
| Lua | `lua` (5.5) | `luarocks install --local <rock>` |
| Perl | `perl -E 'say "hi"'` | `cpanm --local-lib=~/perl5 Mojolicious` |
| Ruby | `ruby -e 'puts 1'`, `irb` | `gem install --user-install`, `bundle` |
| PHP | `php -a`, `php -S localhost:8000` | `composer` |
| Haskell | `ghci`, `cabal init`, `stack new x` | `cabal install`, `ghcup tui` to switch GHC |
| .NET | `dotnet new console -o x && dotnet run --project x` | `dotnet add package` |
| Zig | `zig init && zig build run` | `zig fetch` |

## Updating

```bash
brew upgrade            # erlang, elixir, gleam, lua, ruby, php, mise …
mise upgrade            # node, python, go, java, …
rustup update
ghcup upgrade && ghcup tui
uv self update
npm update -g           # firebase-tools
bash scripts/wsl/install-languages.sh   # .NET: re-run after removing ~/.dotnet, or use dotnet-install.sh --channel LTS
```

## Verify

The script's last step prints every version. To check one later: `mise doctor`, `which -a python node`
(the first path listed should be under `~/.local/share/mise`).

Back to the [README](../README.md).
