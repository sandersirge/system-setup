<#
.SYNOPSIS
  Install Neovim + everything the config needs on Windows, link the config from the repo,
  then install plugins, treesitter parsers and Mason packages headless. Also installs WezTerm
  and copies its config.

.DESCRIPTION
  Run it from YOUR OWN PowerShell (not from inside a packaged app such as the Claude desktop app):
  the %LOCALAPPDATA%\nvim junction it creates would otherwise be redirected into the app's private
  AppData copy and Neovim would never see it (docs/14).

  Needs: winget, Visual Studio Build Tools with the C++ workload (tree-sitter + Rust MSVC),
  Node, Python and Java 21+ (Mason servers). Safe to run again.

.EXAMPLE
  .\scripts\windows\Install-Neovim.ps1
#>
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot)
function Say($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

Say 'winget packages'
foreach ($id in 'Neovim.Neovim', 'BurntSushi.ripgrep.MSVC', 'sharkdp.fd', 'JesseDuffield.lazygit', 'zig.zig', 'Rustlang.Rustup', 'wez.wezterm') {
  winget list --id $id --exact --accept-source-agreements *> $null
  if ($LASTEXITCODE -ne 0) { winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements }
  else { "  $id already installed" }
}
Refresh-Path

Say 'tree-sitter CLI (not on winget)'
$tsDir = Join-Path $env:LOCALAPPDATA 'Programs\tree-sitter'
if (-not (Get-Command tree-sitter -ErrorAction SilentlyContinue)) {
  New-Item -ItemType Directory -Force $tsDir | Out-Null
  $zip = Join-Path $env:TEMP 'tree-sitter.zip'
  Invoke-WebRequest https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-cli-windows-x64.zip -OutFile $zip
  Expand-Archive $zip -DestinationPath $tsDir -Force
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if ($userPath -notlike "*$tsDir*") { [Environment]::SetEnvironmentVariable('Path', "$userPath;$tsDir", 'User') }
  Refresh-Path
}
"  $(tree-sitter --version)"

Say 'Rust toolchain (rustup)'
rustup default stable | Out-Null
rustup component add rust-analyzer rust-src rustfmt clippy 2>&1 | Out-Null
"  $(rustc --version)"

Say 'Neovim config junction'
$link = Join-Path $env:LOCALAPPDATA 'nvim'
$target = Join-Path $repo 'configs\nvim'
$item = Get-Item $link -ErrorAction SilentlyContinue
if ($item -and $item.LinkType -eq 'Junction') { [IO.Directory]::Delete($link, $false) }  # re-point (removes the link only)
elseif ($item) { Rename-Item $link "nvim.bak.$(Get-Date -Format yyyyMMdd-HHmmss)"; "  existing folder renamed to nvim.bak.*" }
New-Item -ItemType Junction -Path $link -Target $target | Out-Null
"  $link -> $target"

Say 'WezTerm config'
$wez = Join-Path $HOME '.wezterm.lua'
if ((Test-Path $wez) -and ((Get-FileHash $wez).Hash -ne (Get-FileHash "$repo\configs\windows\wezterm\.wezterm.lua").Hash)) { Copy-Item $wez "$wez.bak" -Force }
Copy-Item "$repo\configs\windows\wezterm\.wezterm.lua" $wez -Force

Say 'plugins (lazy.nvim)'
nvim --headless "+Lazy! sync" "+qa!" *> $null
Say 'treesitter parsers + Mason packages (first run takes a few minutes)'
nvim --headless -c "luafile $repo\scripts\nvim\bootstrap.lua" 2>&1 | ForEach-Object { "$_" -split '\r?\n' } | Where-Object { $_.Trim() -and $_ -notmatch '^\s*\[' }
Say 'done -> start nvim (or WezTerm); :checkhealth vim.lsp / nvim-treesitter / mason'
