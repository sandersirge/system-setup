# 12 — JetBrains IDEs: moving to Toolbox and cleaning up

## Situation

Standalone IDEs in `C:\Program Files\JetBrains\...` had permission/update problems. Fresh
versions were installed with [JetBrains Toolbox](https://www.jetbrains.com/toolbox-app/), which
installs per user into `%LOCALAPPDATA%\Programs` (no admin rights, updates work):

| IDE | Toolbox path |
|---|---|
| CLion | `%LOCALAPPDATA%\Programs\CLion` |
| IntelliJ IDEA | `%LOCALAPPDATA%\Programs\IntelliJ IDEA` |
| PyCharm | `%LOCALAPPDATA%\Programs\PyCharm` |
| WebStorm / RustRover | same pattern, if installed |

Toolbox's own uninstall entries are per user (`HKCU`).

## 1. Remove stale "Installed apps" entries

The old folders were deleted by hand, so Windows still listed the apps
(`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\<Name>`). From an **elevated**
PowerShell — dry run first, then apply (each key is exported to a `.reg` backup before deletion):

```powershell
.\scripts\windows\Remove-StaleUninstallEntries.ps1 -Name 'CLion 2025.2.5','IntelliJ IDEA 2025.2.5','PyCharm 2025.2.5'
.\scripts\windows\Remove-StaleUninstallEntries.ps1 -Name 'CLion 2025.2.5','IntelliJ IDEA 2025.2.5','PyCharm 2025.2.5' -Apply
```

Expected output:

```text
Removed stale entry: CLion 2025.2.5
Removed stale entry: IntelliJ IDEA 2025.2.5
Removed stale entry: PyCharm 2025.2.5
```

The script refuses a key whose `InstallLocation` still exists. Restore a key by double-clicking its
`.reg` file. Find entry names:

```powershell
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' |
  Get-ItemProperty | Where-Object DisplayName -match 'JetBrains|IntelliJ|CLion|PyCharm|WebStorm|RustRover' |
  Select-Object PSChildName, DisplayName, InstallLocation
```

## 2. Desktop shortcuts

```powershell
.\scripts\windows\New-JetBrainsShortcuts.ps1
```

Searches `%LOCALAPPDATA%\Programs` for `idea64.exe`, `clion64.exe`, `pycharm64.exe`,
`webstorm64.exe`, `rustrover64.exe`. One match → desktop `.lnk` (target, working dir, icon).
None → `Not found`. Several → lists the paths and skips.

## 3. Leftovers in `PATH`

Old entries such as `C:\Program Files\JetBrains\IntelliJ IDEA 2023.3.4\bin` may still be in the
Windows `PATH` (they also appear in WSL's `PATH`). Toolbox can create shell scripts instead:
Toolbox → Settings → *Tools* → **Shell scripts location**
(`%LOCALAPPDATA%\JetBrains\Toolbox\scripts`). Edit `PATH`: Start → *Edit environment variables for your account*.
