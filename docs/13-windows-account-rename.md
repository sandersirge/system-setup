# 13 — Changing the Windows user folder name (`C:\Users\<name>`)

Renaming the account (or the Microsoft account) only changes the display name. The folder name is
chosen once, at the account's first sign-in.

## Option 1 (recommended): new account

1. Settings → Accounts → Other users → **Add account** → *I don't have this person's sign-in
   information* → *Add a user without a Microsoft account* → choose the username you want.
2. Change account type → **Administrator**.
3. Sign in once → `C:\Users\<newname>` is created.
4. Optional: Settings → Accounts → Your info → *Sign in with a Microsoft account instead*
   (the folder keeps the local name).
5. Move data and settings (list below), then delete the old account (Settings → Accounts → Other users).

## Option 2 (not recommended): rename the folder

Rename it from another admin account and edit `ProfileImagePath` under
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\<SID>`. Many apps store the old
path and break silently; a mistake can lock you out.

## What to move for this setup

| Item | Location |
|---|---|
| SSH keys | `~\.ssh` |
| GPG key | `~\.gnupg` (or export/import, [10](10-git-ssh-gpg.md)) |
| Git config | `~\.gitconfig` |
| Git Bash | `~\.bashrc`, `~\.bash_profile` (fix the theme path) |
| PowerShell profile | `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` (fix the theme path, [01a](01a-powershell-profile.md)) |
| Oh My Posh | reinstall per user + copy themes (`Install-WindowsShellConfig.ps1`) |
| Clink script | `%LOCALAPPDATA%\clink\oh-my-posh.lua` |
| Windows Terminal | `settings.json` (fix `backgroundImage`, [01](01-windows-terminal-and-fonts.md#2-windows-terminal-settings-settingsjson)) |
| JetBrains Toolbox + IDEs | reinstall per user, sign in to sync settings |
| WSL distros | registered per user: `wsl --export <distro> <file.tar>` then `wsl --import` in the new account |
| WSL `.zshrc` | theme path `/mnt/c/Users/<old>/...` → new name |

Find every hard-coded old path afterwards:

```bash
grep -rn '/mnt/c/Users/OLD' ~/.zshrc ~/.bashrc 2>/dev/null
```

```powershell
Select-String -Path $PROFILE, "$HOME\.bashrc", "$env:LOCALAPPDATA\clink\*.lua" -Pattern 'Users\\OLD|Users/OLD'
```
