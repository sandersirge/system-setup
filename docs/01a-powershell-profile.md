# 01a — PowerShell 7 profile (`$PROFILE`)

PowerShell runs a profile script at every start — the Windows equivalent of `.zshrc`.
This setup uses **PowerShell 7** (`pwsh`, installed with `winget install Microsoft.PowerShell`),
not the built-in Windows PowerShell 5.1 (hidden in Windows Terminal).

## Which file is `$PROFILE`?

`$PROFILE` is the *current user, current host* profile. All four:

```powershell
$PROFILE | Select-Object AllUsersAllHosts, AllUsersCurrentHost, CurrentUserAllHosts, CurrentUserCurrentHost | Format-List
```

| Variable | PowerShell 7 path | Loaded by |
|---|---|---|
| `$PROFILE.AllUsersAllHosts` | `C:\Program Files\PowerShell\7\profile.ps1` | everyone, every host (admin to edit) |
| `$PROFILE.AllUsersCurrentHost` | `C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1` | everyone, console host |
| `$PROFILE.CurrentUserAllHosts` | `~\Documents\PowerShell\profile.ps1` | you, every host (also VS Code) |
| **`$PROFILE`** (CurrentUserCurrentHost) | **`~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`** | you, console host — **used here** |

Windows PowerShell 5.1 uses `~\Documents\WindowsPowerShell\...` instead. If OneDrive backs up
Documents, the folder is `~\OneDrive\Documents\PowerShell`. `$PROFILE` always shows the real path.

## Create and edit it

```powershell
Test-Path $PROFILE                                            # False = doesn't exist yet
New-Item -ItemType Directory -Force (Split-Path $PROFILE)     # make sure the folder exists
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File $PROFILE }   # never use -Force on the file: it empties it

code $PROFILE       # VS Code
notepad $PROFILE    # Notepad
```

Back up before big edits: `Copy-Item $PROFILE "$PROFILE.bak"`.
Repo copy: [`configs/windows/powershell/Microsoft.PowerShell_profile.ps1`](../configs/windows/powershell/Microsoft.PowerShell_profile.ps1).

## This setup's profile, line by line

```powershell
Import-Module Terminal-Icons

oh-my-posh init pwsh --config 'C:\Users\<you>\AppData\Local\Programs\oh-my-posh\themes\maxed_pc.omp.json' | Invoke-Expression

Set-PSReadLineOption -PredictionViewStyle ListView
```

| Line | Does | Requires |
|---|---|---|
| `Import-Module Terminal-Icons` | file/folder icons and colors in `Get-ChildItem` / `ls` / `dir` | `Install-Module Terminal-Icons -Scope CurrentUser` + Nerd Font |
| `oh-my-posh init pwsh … \| Invoke-Expression` | loads the Oh My Posh prompt with the `maxed_pc` theme | `winget install JanDeDobbeleer.OhMyPosh` ([06](06-oh-my-posh.md)) |
| `Set-PSReadLineOption -PredictionViewStyle ListView` | history-based suggestions as a dropdown list (`↑`/`↓` to pick, `F2` toggles inline/list) | PSReadLine 2.2+ (ships with PowerShell 7) |

`ListView` needs a console of at least 50×5 characters. In tiny panes PowerShell prints
*"The prediction 'ListView' is temporarily disabled because the current window size of the
console is too small"* — harmless, it switches back when the window is bigger.

Optional, common additions:

```powershell
Set-PSReadLineOption -PredictionSource HistoryAndPlugin      # history + plugin predictions
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete      # zsh-like Tab menu
Set-PSReadLineOption -EditMode Windows                        # or Emacs
Set-Alias ll Get-ChildItem
function .. { Set-Location .. }
```

## Modules

```powershell
Install-Module Terminal-Icons -Scope CurrentUser -Repository PSGallery
Update-Module Terminal-Icons
Get-Module Terminal-Icons, PSReadLine -ListAvailable | Select-Object Name, Version
```

The first `Install-Module` may ask to trust PSGallery (`Set-PSRepository PSGallery -InstallationPolicy Trusted`
to stop asking) and to install the NuGet provider — answer **Y**.

## Execution policy (running `.ps1` files)

```powershell
Get-ExecutionPolicy -List
```

This machine: `LocalMachine = RemoteSigned`. That allows local scripts (your profile and this
repo's `scripts\windows\*.ps1`) and blocks unsigned *downloaded* ones. Files downloaded from the
internet (e.g. a repo zip) carry a "mark of the web":

```powershell
Get-ChildItem .\scripts\windows\*.ps1 | Unblock-File
```

If the policy is `Restricted` (default on some machines), allow local scripts for your user only:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Run a repo script once without changing anything: `pwsh -ExecutionPolicy Bypass -File .\scripts\windows\Remove-JsonBom.ps1 <file>`.

## Reload, test, measure

| Task | Command |
|---|---|
| Reload after editing | `. $PROFILE` (or open a new tab) |
| Start without the profile | `pwsh -NoProfile` |
| Find a broken line | `pwsh -NoProfile`, then `. $PROFILE` and read the error |
| Startup time | `Measure-Command { pwsh -Command exit }` vs `Measure-Command { pwsh -NoProfile -Command exit }` |
| Oh My Posh problems | `oh-my-posh debug --shell pwsh` |

## Handy environment variables for this setup

| Variable | Why |
|---|---|
| `$env:WSL_UTF8 = 1` | makes `wsl.exe` output UTF-8, so `wsl -l -v` etc. aren't garbled with spaces when piped in PowerShell |
| `$env:POSH_THEMES_PATH` | set by Oh My Posh; the themes folder |

Put `$env:WSL_UTF8 = 1` in the profile if you script `wsl.exe` often.
