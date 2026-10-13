<#
.SYNOPSIS
  Add a "Git Bash" profile to Windows Terminal (right after Command Prompt).

.DESCRIPTION
  Inserts configs\windows\windows-terminal\git-bash-profile.json into the Windows Terminal
  settings.json profile list. Backs up settings.json as settings.json.bak first and
  does nothing if a profile named "Git Bash" already exists. Windows Terminal reloads
  the file automatically.
#>
$ErrorActionPreference = 'Stop'
$repo     = Split-Path (Split-Path $PSScriptRoot)
$settings = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState\settings.json" | Select-Object -First 1 -ExpandProperty FullName
if (-not $settings) { throw 'Windows Terminal settings.json not found' }
if (-not (Test-Path 'C:\Program Files\Git\bin\bash.exe')) { throw 'Git for Windows is not installed (winget install Git.Git)' }

$json = Get-Content $settings -Raw | ConvertFrom-Json
if ($json.profiles.list | Where-Object name -eq 'Git Bash') { 'Git Bash profile already exists'; return }

Copy-Item $settings "$settings.bak" -Force
$gitBash = Get-Content "$repo\configs\windows\windows-terminal\git-bash-profile.json" -Raw | ConvertFrom-Json
$list = [Collections.ArrayList]@($json.profiles.list)
$cmd  = $list | Where-Object name -eq 'Command Prompt' | Select-Object -First 1
$list.Insert($(if ($cmd) { $list.IndexOf($cmd) + 1 } else { $list.Count }), $gitBash)
$json.profiles.list = @($list)
[IO.File]::WriteAllText($settings, ($json | ConvertTo-Json -Depth 50), [Text.UTF8Encoding]::new($false))
"added Git Bash profile (backup: $settings.bak)"
