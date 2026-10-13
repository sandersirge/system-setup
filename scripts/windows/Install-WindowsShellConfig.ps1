<#
.SYNOPSIS
  Install the Oh My Posh themes and the PowerShell / cmd (Clink) / Git Bash prompt configs.

.DESCRIPTION
  - copies configs\oh-my-posh\themes\*.omp.json to the Oh My Posh themes folder (UTF-8, no BOM)
  - PowerShell: adds the oh-my-posh init line for maxed_pc to $PROFILE if it is missing
  - cmd: writes %LOCALAPPDATA%\clink\oh-my-posh.lua (needs Clink installed)
  - Git Bash: writes ~/.bashrc and ~/.bash_profile (maxed_bash_pc)
  Existing files are backed up as *.bak before being replaced.

  Prerequisites: winget install JanDeDobbeleer.OhMyPosh ; winget install chrisant996.Clink
#>
$ErrorActionPreference = 'Stop'
$repo   = Split-Path (Split-Path $PSScriptRoot)
$themes = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\themes'
$utf8   = [Text.UTF8Encoding]::new($false)

function Write-Config([string]$Path, [string]$Content) {
    if ((Test-Path $Path) -and ((Get-Content $Path -Raw) -ne $Content)) { Copy-Item $Path "$Path.bak" -Force }
    New-Item -ItemType Directory -Force (Split-Path $Path) | Out-Null
    [IO.File]::WriteAllText($Path, $Content, $utf8)
    "wrote $Path"
}

# 1. themes
New-Item -ItemType Directory -Force $themes | Out-Null
Get-ChildItem "$repo\configs\oh-my-posh\themes\*.omp.json" | ForEach-Object {
    Write-Config (Join-Path $themes $_.Name) ([IO.File]::ReadAllText($_.FullName).TrimStart([char]0xFEFF))
}
$fwd = $themes -replace '\\', '/'

# 2. PowerShell profile
$init = "oh-my-posh init pwsh --config '$themes\maxed_pc.omp.json' | Invoke-Expression"
if (-not (Test-Path $PROFILE) -or -not (Select-String -Path $PROFILE -Pattern 'oh-my-posh init pwsh' -Quiet)) {
    New-Item -ItemType Directory -Force (Split-Path $PROFILE) | Out-Null
    Add-Content -Path $PROFILE -Value "`n$init"
    "added Oh My Posh to $PROFILE"
} else {
    "PowerShell profile already initializes Oh My Posh (check that it points to maxed_pc): $PROFILE"
}

# 3. cmd via Clink
Write-Config "$env:LOCALAPPDATA\clink\oh-my-posh.lua" "load(io.popen('oh-my-posh init cmd --config $fwd/maxed_pc.omp.json'):read('*a'))()`n"

# 4. Git Bash
Write-Config "$HOME\.bashrc"       "eval `"`$(oh-my-posh init bash --config '$fwd/maxed_bash_pc.omp.json')`"`n"
Write-Config "$HOME\.bash_profile" "test -f ~/.bashrc && . ~/.bashrc`n"

"done - open new PowerShell / cmd / Git Bash windows"
