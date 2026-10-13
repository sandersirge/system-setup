# 01 — Windows Terminal, Nerd Font and Windows shells

Everything visual (fonts, colors, transparency) is handled by **Windows Terminal on Windows**.
Linux distros never need a font installed: WSL only sends characters, Windows Terminal draws them.

## 1. Nerd Font

All prompts and `ls` icons use **Nerd Font** glyphs. The setup uses **JetBrainsMono Nerd Font** (v3).

1. Download from <https://www.nerdfonts.com/font-downloads> (JetBrainsMono), or with Oh My Posh:

   ```powershell
   oh-my-posh font install JetBrainsMono
   ```

2. Select the `.ttf` files → right-click → **Install for all users**.
3. Use it in Windows Terminal (below).

> **Nerd Fonts v3 moved the Material Design icons** from `U+F500–U+FD46` to `U+F0001+`.
> Tools that were never updated (e.g. the original `logo-ls`) print `?` boxes with any v3 font.
> Fix the tool, not the font — see [09](09-ls-colors-and-cli-tools.md).

Check whether a glyph exists in the font (PowerShell):

```powershell
Add-Type -AssemblyName PresentationCore
$gt = [Windows.Media.GlyphTypeface]::new([Uri]'C:\Windows\Fonts\JetBrainsMonoNLNerdFontPropo-ExtraBold.ttf')
$gt.CharacterToGlyphMap.ContainsKey(0xF303)   # True = the Arch logo exists
```

Glyph search: <https://www.nerdfonts.com/cheat-sheet>

## 2. Windows Terminal settings (`settings.json`)

### Where it is and how to open it

| Install type | Path |
|---|---|
| Microsoft Store / winget (this machine) | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| Windows Terminal Preview | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json` |
| Unpackaged (zip / scoop) | `%LOCALAPPDATA%\Microsoft\Windows Terminal\settings.json` |

Ways to open it:

- In Windows Terminal: `Ctrl+Shift+,` (opens the JSON directly), or Settings (`Ctrl+,`) →
  **Open JSON file** (bottom left).
- Hold `Alt` while clicking **Open JSON file** → opens `defaults.json` (read-only reference of
  every built-in default; copy keys from there into `settings.json`).
- From PowerShell:

  ```powershell
  $wt = (Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json").FullName
  code $wt          # or: notepad $wt
  ```

Windows Terminal **reloads the file on save** — no restart needed. If the JSON is invalid it shows
a warning banner and keeps the last good settings.

### Before editing: back up, after editing: validate

```powershell
Copy-Item $wt "$wt.bak"
Get-Content $wt -Raw | ConvertFrom-Json | Out-Null; "valid JSON"
```

Comments (`//`) are allowed in this file. Restore: copy the `.bak` back. Full reset: delete
`settings.json` and Windows Terminal regenerates it (your profiles' customizations are lost).

### Structure

The current file is in the repo: [`configs/windows/windows-terminal/settings.json`](../configs/windows/windows-terminal/settings.json).

| Key | What it holds | This setup |
|---|---|---|
| `defaultProfile` | GUID of the profile a new window opens with | PowerShell 7 `{574e775e-…}` |
| `profiles.defaults` | settings applied to **every** profile | font, colors, opacity, background (below) |
| `profiles.list` | one object per profile (`name`, `guid`, `commandline` or `source`, `icon`, `hidden`, `startingDirectory`, per-profile overrides) | PowerShell, Command Prompt, Git Bash, six WSL distros, Windows PowerShell (hidden) |
| `actions` | commands with ids (`copy`, `paste`, `splitPane`, `find`, …) | see keys below |
| `keybindings` | key → action id | `ctrl+c` copy, `ctrl+v` paste, `ctrl+shift+f` find, `alt+shift+d` split pane (duplicate) |
| `schemes` | custom color schemes | none (built-in `Dimidium`) |
| `themes` | window/tab chrome themes | none |
| `newTabMenu` | the `˅` dropdown content | `remainingProfiles` |
| top-level options | `copyOnSelect`, `copyFormatting`, `useAcrylicInTabRow`, `alwaysShowNotificationIcon` | as in the file |

Common edits:

```jsonc
// change the default tab: copy the profile's guid into defaultProfile
"defaultProfile": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",

// hide a profile from the dropdown (WSL profiles come back automatically if deleted)
{ "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}", "name": "Windows PowerShell", "hidden": true },

// per-profile override, e.g. a different font size only for Git Bash
{ "name": "Git Bash", "font": { "size": 12 } }
```

The Settings UI doesn't show GUIDs: find a profile's GUID by searching the JSON for its `"name"`.
WSL profiles use `"source": "Microsoft.WSL"` and are generated per distro. List them all:

```powershell
(Get-Content $wt -Raw | ConvertFrom-Json).profiles.list | Select-Object name, guid, source, hidden
```

### Profile defaults used here

[`configs/windows/windows-terminal/profile-defaults.json`](../configs/windows/windows-terminal/profile-defaults.json):

```json
"profiles": {
  "defaults": {
    "font": { "face": "JetBrainsMono Nerd Font", "size": 14, "weight": "extra-bold" },
    "colorScheme": "Dimidium",
    "cursorShape": "filledBox",
    "cursorColor": "#67FFEA",
    "opacity": 70,
    "useAcrylic": true,
    "backgroundImage": "%USERPROFILE%\\Downloads\\wallpaper.jpg",
    "backgroundImageOpacity": 0.05
  }
}
```

Each WSL distro gets its own profile automatically (`"source": "Microsoft.WSL"`).

### Git Bash profile

Windows Terminal does not add Git Bash by itself. Add it with the script (backs up `settings.json`):

```powershell
.\scripts\windows\Add-GitBashTerminalProfile.ps1
```

or paste [`git-bash-profile.json`](../configs/windows/windows-terminal/git-bash-profile.json) into `profiles.list`:

```json
{
    "commandline": "\"C:\\Program Files\\Git\\bin\\bash.exe\" -i -l",
    "guid": "{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}",
    "icon": "C:\\Program Files\\Git\\ucrt64\\share\\git\\git-for-windows.ico",
    "name": "Git Bash",
    "startingDirectory": "%USERPROFILE%"
}
```

`-i -l` = interactive login shell, so `~/.bash_profile` → `~/.bashrc` load.
Make it the default tab: Settings → Startup → Default profile.

## 3. Oh My Posh on Windows (PowerShell, cmd, Git Bash)

Install:

```powershell
winget install JanDeDobbeleer.OhMyPosh
winget install chrisant996.Clink        # needed for cmd
```

Then install the themes and all three shell configs from this repo:

```powershell
.\scripts\windows\Install-WindowsShellConfig.ps1
```

What it sets up (copies in [`configs/windows`](../configs/windows)):

| Shell | File | Theme |
|---|---|---|
| PowerShell 7 | `$PROFILE` (`Documents\PowerShell\Microsoft.PowerShell_profile.ps1`) | `maxed_pc` |
| cmd | `%LOCALAPPDATA%\clink\oh-my-posh.lua` | `maxed_pc` |
| Git Bash | `~/.bashrc` + `~/.bash_profile` | `maxed_bash_pc` |

PowerShell profile ([file](../configs/windows/powershell/Microsoft.PowerShell_profile.ps1)):

```powershell
Import-Module Terminal-Icons
oh-my-posh init pwsh --config "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\maxed_pc.omp.json" | Invoke-Expression
Set-PSReadLineOption -PredictionViewStyle ListView
```

Everything about `$PROFILE` (which file, editing, modules, execution policy, reload, speed):
[01a — PowerShell profile](01a-powershell-profile.md).

**cmd needs Clink**: cmd cannot run a prompt engine itself. Clink injects into every cmd window
(`HKCU\Software\Microsoft\Command Processor\AutoRun`) and loads every `.lua` file from its
scripts folder (`clink info` lists it, normally `%LOCALAPPDATA%\clink`):

```lua
load(io.popen('oh-my-posh init cmd --config C:/Users/<you>/AppData/Local/Programs/oh-my-posh/themes/maxed_pc.omp.json'):read('*a'))()
```

**Git Bash** `~/.bashrc` / `~/.bash_profile`:

```bash
eval "$(oh-my-posh init bash --config 'C:/Users/<you>/AppData/Local/Programs/oh-my-posh/themes/maxed_bash_pc.omp.json')"
```

```bash
test -f ~/.bashrc && . ~/.bashrc
```

Themes, auto-upgrade, segments and every prompt fix: [06 — Oh My Posh](06-oh-my-posh.md).

## 4. Reloading after changes

| Shell | Reload in place |
|---|---|
| PowerShell | `. $PROFILE` |
| cmd | close and reopen (Clink loads scripts at start) |
| Git Bash | `source ~/.bashrc` |
| WSL zsh | `exec zsh` |
| tmux | `tmux source ~/.tmux.conf` (server-level options: `tmux kill-server`) |
