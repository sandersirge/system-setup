<#
.SYNOPSIS
  Open the Arch Linux XFCE desktop (WSL) in Windows Remote Desktop.

.DESCRIPTION
  Starts Arch in the background with a hidden keep-alive process (WSL stops an idle distro a few
  seconds after its last window closes, which would end the desktop), waits for xrdp on
  localhost:3390, then opens Remote Desktop. Log in with your Arch username and password.
  Stop the desktop afterwards with:  .\Start-ArchDesktop.ps1 -Stop   (or: wsl -t archlinux)
  Setup: scripts/wsl/install-arch-rdp.sh inside Arch (docs/20-arch-remote-desktop.md).
#>
param(
    [string]$Distro = 'archlinux',
    [int]$Port = 3390,
    [switch]$Stop
)

if ($Stop) {
    wsl --terminate $Distro
    "Stopped $Distro."
    return
}

# Hidden keep-alive: a sleeping process keeps the distro (and xrdp) running
$alive = Get-CimInstance Win32_Process -Filter "Name='wsl.exe'" |
    Where-Object { $_.CommandLine -match "-d $Distro .*sleep infinity" }
if (-not $alive) {
    Start-Process wsl.exe -ArgumentList "-d $Distro --exec sleep infinity" -WindowStyle Hidden
}

# Wait for xrdp (systemd starts it with the distro)
$ok = $false
foreach ($i in 1..30) {
    if ((Test-NetConnection localhost -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded) { $ok = $true; break }
    Start-Sleep -Milliseconds 500
}
if (-not $ok) {
    Write-Warning "xrdp isn't answering on localhost:$Port. In Arch: systemctl status xrdp xrdp-sesman"
    return
}

mstsc.exe /v:localhost:$Port
