<#
.SYNOPSIS
  Remove stale "Installed apps" entries left behind after an app folder was deleted by hand.

.DESCRIPTION
  Used for the old standalone JetBrains IDEs (C:\Program Files\JetBrains\...) after moving
  to JetBrains Toolbox. For each named key under
  HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall it exports a .reg backup to
  -BackupDir, then deletes the key. Per-user (HKCU) Toolbox entries are not touched.

  Runs as a dry run unless -Apply is given. Needs an elevated (Administrator) PowerShell.
  Restore a key by double-clicking its .reg backup.

.EXAMPLE
  .\Remove-StaleUninstallEntries.ps1 -Name 'CLion 2025.2.5','IntelliJ IDEA 2025.2.5','PyCharm 2025.2.5'
  .\Remove-StaleUninstallEntries.ps1 -Name 'CLion 2025.2.5','IntelliJ IDEA 2025.2.5','PyCharm 2025.2.5' -Apply
#>
param(
    [Parameter(Mandatory)][string[]]$Name,
    [string]$BackupDir = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Stale-Uninstall-Entries-Backup'),
    [switch]$Apply
)
$base = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
if ($Apply -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')) {
    throw 'Run this from an elevated (Administrator) PowerShell.'
}
New-Item -ItemType Directory -Force $BackupDir | Out-Null

foreach ($n in $Name) {
    $key = "$base\$n"
    if (-not (Test-Path "Registry::$key")) { "Not found: $n"; continue }
    $props = Get-ItemProperty "Registry::$key"
    $loc = $props.InstallLocation
    if ($loc -and (Test-Path $loc)) { "SKIPPED (install folder still exists: $loc): $n"; continue }
    if (-not $Apply) { "Would remove: $n  [$($props.DisplayName) $($props.DisplayVersion)]"; continue }
    $file = Join-Path $BackupDir (($n -replace '[\\/:*?"<>|]', '_') + '.reg')
    reg export $key $file /y | Out-Null
    reg delete $key /f | Out-Null
    "Removed stale entry: $n  (backup: $file)"
}
