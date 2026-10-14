# 16 — Neovim (Josean's setup on Windows + WSL) and advanced tmux

Neovim configured after Josean Martinez's guide and his current
[dev-environment-files](https://github.com/josean-dev/dev-environment-files) (Neovim 0.11+ version),
step by step and validated on **WSL Ubuntu** and **Windows**. One config, in
[`configs/nvim/`](../configs/nvim), shared by both. Lua namespace: `sander`.

The advanced **tmux** part of his setup is still **TBD** ([at the end](#tmux-advanced-setup-tbd)).

## Terminal: WezTerm (instead of iTerm2)

The guide uses iTerm2, which is macOS-only. WezTerm is the cross-platform equivalent and Josean's
repo has a `.wezterm.lua`. Windows version: [`configs/windows/wezterm/.wezterm.lua`](../configs/windows/wezterm/.wezterm.lua).

```powershell
winget install wez.wezterm
Copy-Item "$HOME\Downloads\comp-setup\configs\windows\wezterm\.wezterm.lua" "$HOME\.wezterm.lua"
```

| Change vs. his config | Why |
|---|---|
| font JetBrainsMono Nerd Font 13 (his: MesloLGS 19) | already installed; 19 is sized for Retina |
| `default_domain = "WSL:Ubuntu"` + PowerShell 7 in the launcher | start in Ubuntu |
| `window_decorations = "TITLE\|RESIZE"` (his: `RESIZE`) | `RESIZE` removes the title bar → window can't be moved/closed on Windows |
| tab bar shown when 2+ tabs (his: off) | his tabs live in tmux |
| `Ctrl+Alt+P` new PowerShell tab, `Ctrl+Alt+L` launcher | defaults: `Ctrl+Shift+T` new tab, `Ctrl+Tab` next, `Ctrl+Shift+W` close, `Ctrl+Shift+P` palette |

His "coolnight" colors are unchanged and match the Neovim theme.

## 1. Prerequisites

| Tool | Ubuntu (WSL) | Windows |
|---|---|---|
| Neovim 0.12 | `brew install neovim` (apt is too old) | `winget install Neovim.Neovim` |
| ripgrep, fd | `brew install ripgrep fd` | `winget install BurntSushi.ripgrep.MSVC sharkdp.fd` |
| lazygit | `brew install lazygit` | `winget install JesseDuffield.lazygit` |
| tree-sitter CLI ≥ 0.26.1 | `brew install tree-sitter-cli` | GitHub release zip → `%LOCALAPPDATA%\Programs\tree-sitter` + PATH (below) |
| C compiler | `build-essential` (gcc) | Visual Studio Build Tools (C++) — tree-sitter finds it; `winget install zig.zig` for telescope-fzf-native |
| Node / Python / Java 21+ | base packages (Node 22, Python 3.15 via brew, OpenJDK 25) | Node, Python 3.15, Java 23 |
| Rust (rust-analyzer, rustfmt) | `curl https://sh.rustup.rs -sSf \| sh -s -- -y` + `rustup component add rust-analyzer rust-src rustfmt clippy` | `winget install Rustlang.Rustup`, then `rustup default stable` + same components |
| clipboard | `win32yank.exe` in `~/.local/bin` ([releases](https://github.com/equalsraf/win32yank/releases)) | built in |

tree-sitter CLI on Windows (not on winget):

```powershell
New-Item -ItemType Directory -Force "$env:LOCALAPPDATA\Programs\tree-sitter"
Invoke-WebRequest https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.1/tree-sitter-cli-windows-x64.zip -OutFile "$env:TEMP\tree-sitter.zip"
Expand-Archive "$env:TEMP\tree-sitter.zip" -DestinationPath "$env:LOCALAPPDATA\Programs\tree-sitter" -Force
[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ";$env:LOCALAPPDATA\Programs\tree-sitter", 'User')
```

## 2. Link the config (both systems use the repo folder)

```bash
# WSL Ubuntu
ln -s /mnt/c/Users/sande/Downloads/comp-setup/configs/nvim ~/.config/nvim
```

```powershell
# Windows — run in YOUR shell (a link created from a packaged app such as the Claude desktop
# app is redirected into the app's private AppData copy and Neovim never sees it)
New-Item -ItemType Junction -Path $env:LOCALAPPDATA\nvim -Target $HOME\Downloads\comp-setup\configs\nvim
```

Check: `:echo $MYVIMRC` → the `init.lua` path. First start installs all plugins (lazy.nvim),
26 treesitter parsers and 20 Mason packages; restart once afterwards.

## 3. Layout

```text
configs/nvim/
  init.lua                       require sander.core / sander.lazy / sander.lsp
  lazy-lock.json                 pinned plugin versions (written by lazy.nvim)
  after/lsp/                     per-server overrides: emmet_ls, graphql, svelte
  after/queries/ecma/            custom JS/TS object-property textobjects
  lua/sander/core/               options.lua, keymaps.lua
  lua/sander/lazy.lua            lazy.nvim bootstrap
  lua/sander/lsp.lua             LspAttach keymaps, diagnostic signs, rust-analyzer
  lua/sander/plugins/*.lua       one file per plugin
  lua/sander/plugins/lsp/        mason.lua, lsp.lua
```

## 4. Plugins and keys (leader = `Space`)

| Plugin | Keys / what it does |
|---|---|
| core keymaps | `jk` leave insert · `Space nh` clear search · `Space +/-` increment · `Space sv/sh/se/sx` splits · `Space to/tx/tn/tp/tf` tabs |
| vim-tmux-navigator | `Ctrl+h/j/k/l` between splits and tmux panes |
| tokyonight | "night" style with Josean's coolnight colors |
| nvim-tree | `Space ee` toggle · `ef` find file · `ec` collapse · `er` refresh · in tree: `a` add, `r` rename, `d` delete, `Ctrl+]` cd into folder, `-` up, `g?` help |
| which-key | popup of next keys after `Space`, `g`, `[`, `]`… (500 ms) |
| telescope (+ fzf-native) | `Space ff` files · `fs` live grep · `fc` word under cursor · `fr` recent · `fk` keymaps · `ft` todos · in list: `Ctrl+j/k` move, `Ctrl+q` → quickfix + trouble, `Ctrl+t` → trouble |
| alpha-nvim | welcome screen with the NEOVIM logo |
| auto-session | `Space ws` save · `Space wr` restore session for the cwd |
| bufferline | tab bar (slanted); clicking `x` on the last tab quits with `:confirm qall` |
| lualine | status line: mode, branch, file, encoding, **line endings (Tux/Windows)**, **current OS logo**, filetype, position, pending updates |
| dressing.nvim | nicer `vim.ui.select` / `vim.ui.input` prompts (code actions, rename) |
| vim-maximizer | `Space sm` maximize / restore a split |
| nvim-treesitter (main) | highlighting + indent for 26 languages · `Ctrl+Space` grow / `Backspace` shrink selection |
| treesitter-textobjects (main) | `af/if` call · `am/im` function · `ac/ic` class · `aa/ia` argument · `ai/ii` conditional · `al/il` loop · `a=/i=` assignment · `]m [m ]f [f ]c [c…` move · `;` `,` repeat · `Space na/pa` swap |
| nvim-ts-autotag | auto close / rename HTML, JSX, Svelte tags |
| indent-blankline | `┊` indent guides |
| nvim-cmp + LuaSnip + friendly-snippets | completion: `Ctrl+j/k` select, `Enter` confirm, `Ctrl+Space` open, `Ctrl+e` close, `Ctrl+f/b` scroll docs |
| nvim-autopairs | auto-close `( [ { " '` (treesitter-aware) |
| todo-comments | highlight `TODO/FIXME/NOTE/HACK/WARN/PERF` · `]t` / `[t` jump |
| substitute.nvim | `Space r` + motion · `Space rr` line · `Space R` to end of line (replace with yanked text) |
| nvim-surround | `ys{motion}{char}` add · `cs{old}{new}` change · `ds{char}` delete · `S` in visual mode |
| Mason (+ mason-lspconfig v2, tool-installer) | `:Mason` · servers: ts_ls, html, cssls, tailwindcss, svelte, lua_ls, graphql, emmet_ls, prismals, pyright, eslint, **jdtls**, **clangd** · tools: prettier, stylua, isort, black, pylint, eslint_d, **clang-format** |
| LSP (Neovim built-in) | `gd` definition · `gD` declaration · `gR` references · `gi` implementations · `gt` type defs · `K` hover · `Space ca` code action · `Space rn` rename · `Space d/D` diagnostics · `[d ]d` · `Space rs` restart |
| trouble.nvim | `Space xw` workspace / `xd` document diagnostics · `xq` quickfix · `xl` loclist · `xt` todos |
| conform.nvim | format on save (prettier, stylua, isort+black, **clang-format**, **rustfmt**, LSP fallback e.g. Java) · `Space mp` format |
| nvim-lint | pylint for Python (on open, save, leave insert) · `Space l` lint now |
| gitsigns | `]h [h` hunks · `Space hs/hr` stage/reset hunk · `hS/hR` buffer · `hu` undo stage · `hp` preview · `hb/hB` blame · `hd/hD` diff · `ih` textobject |
| lazygit.nvim | `Space lg` lazygit in a float |

Built in (no plugin): `gcc` / `gc{motion}` comment (Comment.nvim from the article is not needed on Neovim 0.10+).
Skipped like his repo: flash.nvim, the ChatGPT plugin (`ai.lua`).

## 5. Differences from Josean's config (and why)

| Change | Reason |
|---|---|
| namespace `sander` | own config |
| `vim.uv` instead of `vim.loop` (lazy.lua, linting.lua) | deprecated since Neovim 0.10 |
| which-key **enabled** | commented out in his repo; useful while learning the keys |
| telescope `branch = "master"` (his `0.1.x`) | `0.1.x` preview calls `nvim-treesitter.parsers.ft_to_lang` → crash with nvim-treesitter main |
| fzf-native built with **zig** on Windows | `make` doesn't exist on Windows |
| nvim-treesitter + textobjects on **`main`** (his pins `master`) | `master` is frozen; ported to the new API; selection keys mapped to Neovim 0.12's `an`/`in` |
| treesitter move keys guarded | textobjects bug: `]m` etc. crash in buffers without a parser |
| parsers + `java cpp rust python toml regex` | the languages set up in Mason |
| bufferline `separator_style = "slant"` + own `close_command` | slant from the article; `:tabclose` on the last tab gave E784 |
| auto-session `sessionoptions += localoptions` | `:checkhealth auto-session` |
| lualine: line-ending block (Tux/Windows) + current-OS block | his showed the Apple logo |
| nvim-tree `number = true` | cursor line showed `0` in the tree and in files opened from it |
| LuaSnip `jsregexp` built only on Linux | needs `make` |
| Mason: + jdtls, clangd, clang-format; stylua excluded from auto-enable | your languages; stylua is a formatter |
| rust-analyzer from rustup (`vim.lsp.enable`) | matches the installed toolchain |
| his `after/lsp/eslint.lua` dropped | its filetypes excluded JS/TS |
| conform `lsp_format = "fallback"`, + clang-format, rustfmt; isort args on Windows | renamed option; your languages; cmd.exe mangles `--line-ending` |
| diagnostic sign icons as `\u{…}` escapes | glyphs survive copy/edit |

## 6. Verify

```vim
:checkhealth vim.lsp
:checkhealth nvim-treesitter
:checkhealth mason
:Lazy
:Mason
:ConformInfo
```

Expected harmless messages: Mason warns about missing `go`, `ruby`, `php`… (only needed for
packages built with them); `vim.lsp` warns about unknown filetypes listed by tailwind/emmet;
`E216 FileExplorer` in `v:errmsg` (nvim-tree removing netrw's autocmds).

Neovim-specific errors and fixes are in [14 — Troubleshooting](14-troubleshooting.md).

## tmux advanced setup (TBD)

Planned: Josean's tmux setup (prefix, keys, theme, his plugin list) on top of [08 — tmux](08-tmux.md).

## References

- Josean Martinez — *How to set up tmux* — <https://www.josean.com/posts/tmux-setup>
- Josean Martinez — *How to set up Neovim (2024)* — <https://www.josean.com/posts/how-to-setup-neovim-2024>
- Josean Martinez — dev environment files — <https://github.com/josean-dev/dev-environment-files>
- WezTerm — <https://wezterm.org/>
- lazy.nvim — <https://lazy.folke.io/>
- nvim-treesitter (main) — <https://github.com/nvim-treesitter/nvim-treesitter>
- Mason — <https://github.com/mason-org/mason.nvim>
- Neovim LSP (`:h lsp`) — <https://neovim.io/doc/user/lsp.html>

Back to the [README](../README.md).
