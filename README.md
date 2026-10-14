# system-setup

Documentation, configs and scripts for setting up this whole computer: Windows 11 with Windows
Terminal, a Nerd Font, PowerShell, cmd and Git Bash prompts, Git/GPG signing, Docker Desktop and
JetBrains Toolbox — and six WSL 2 Linux distros with zsh, Oh My Posh (or Oh My Zsh +
Powerlevel10k), tmux, Homebrew, icon-aware `ls` and colorized command output. Every fix found
along the way is documented.

## Table of contents

- [Overview](#overview)
- [Setup order](#setup-order)
  - [Windows](#windows)
  - [Each WSL distro](#each-wsl-distro)
- [Checklist](#checklist)
- [Repository layout](#repository-layout)
- [Conventions](#conventions)
- **Documentation**
  - **Windows**
    - [01 — Windows Terminal, Nerd Font and Windows shells](docs/01-windows-terminal-and-fonts.md)
      - [Nerd Font](docs/01-windows-terminal-and-fonts.md#1-nerd-font)
      - [Windows Terminal `settings.json`: open, back up, structure, common edits](docs/01-windows-terminal-and-fonts.md#2-windows-terminal-settings-settingsjson)
      - [Oh My Posh in PowerShell, cmd (Clink) and Git Bash](docs/01-windows-terminal-and-fonts.md#3-oh-my-posh-on-windows-powershell-cmd-git-bash)
      - [Reloading after changes (every shell)](docs/01-windows-terminal-and-fonts.md#4-reloading-after-changes)
    - [01a — PowerShell 7 profile (`$PROFILE`)](docs/01a-powershell-profile.md)
      - [Which file is `$PROFILE`?](docs/01a-powershell-profile.md#which-file-is-profile)
      - [Create and edit it](docs/01a-powershell-profile.md#create-and-edit-it)
      - [This setup's profile, line by line](docs/01a-powershell-profile.md#this-setups-profile-line-by-line)
      - [Windows PowerShell 5.1 and admin windows look different](docs/01a-powershell-profile.md#windows-powershell-51-and-admin-windows-look-different)
      - [Modules](docs/01a-powershell-profile.md#modules)
      - [Execution policy](docs/01a-powershell-profile.md#execution-policy-running-ps1-files)
      - [Reload, test, measure](docs/01a-powershell-profile.md#reload-test-measure)
      - [Handy environment variables](docs/01a-powershell-profile.md#handy-environment-variables-for-this-setup)
  - **WSL**
    - [02 — WSL basics, distros and users](docs/02-wsl-basics.md)
      - [Distros in this setup](docs/02-wsl-basics.md#distros-in-this-setup)
      - [Everyday WSL commands](docs/02-wsl-basics.md#everyday-wsl-commands-powershell--cmd)
      - [Arch Linux: create a sudo user, default user](docs/02-wsl-basics.md#arch-linux-create-a-sudo-user-fresh-install-starts-as-root)
      - [systemd "State: degraded"](docs/02-wsl-basics.md#systemd-state-degraded-in-systemctl-status)
      - [Accessing files between Windows and Linux](docs/02-wsl-basics.md#accessing-files)
    - [03 — Base packages (per-distro scripts)](docs/03-base-packages.md) · [scripts README](scripts/wsl/base-packages/README.md)
      - [Run](docs/03-base-packages.md#run)
      - [What gets installed](docs/03-base-packages.md#what-gets-installed)
      - [Fedora additions (`awk`, `clear`, `chsh`)](docs/03-base-packages.md#fedora-additions-found-missing-during-setup)
    - [04 — zsh in every distro (Kali's config)](docs/04-zsh.md)
      - [Install zsh](docs/04-zsh.md#1-install-zsh)
      - [Make zsh the login shell (`chsh` + `/usr/sbin` gotcha)](docs/04-zsh.md#2-make-zsh-the-login-shell)
      - [The shared `.zshrc`](docs/04-zsh.md#3-the-zshrc-kalis-shared-by-all-distros)
      - [Plugins](docs/04-zsh.md#4-plugins)
      - [TERM and COLORTERM](docs/04-zsh.md#5-term-and-colorterm)
      - [After editing (`exec zsh`)](docs/04-zsh.md#6-after-editing)
    - [05 — Homebrew in every distro](docs/05-homebrew.md)
      - [Prerequisites](docs/05-homebrew.md#1-prerequisites-sudo)
      - [Install](docs/05-homebrew.md#2-install-in-every-distro-asks-for-your-sudo-password--enter)
      - [Add brew to zsh](docs/05-homebrew.md#3-add-brew-to-zsh)
      - [Verify](docs/05-homebrew.md#4-verify) · [Tips](docs/05-homebrew.md#tips)
  - **Prompt, terminal tools**
    - [06 — Oh My Posh](docs/06-oh-my-posh.md)
      - [Install and init lines](docs/06-oh-my-posh.md#install)
      - [Themes (`maxed`, `_pc` variants)](docs/06-oh-my-posh.md#themes-in-this-repo)
      - [Auto-upgrade](docs/06-oh-my-posh.md#auto-upgrade)
      - [Technology segments (docker, npm, aws, kubectl, …)](docs/06-oh-my-posh.md#segments-added-for-detected-technologies)
      - [OS icon fix (Arch / Fedora)](docs/06-oh-my-posh.md#os-icon-fix-arch--fedora-showed-tux)
      - [Fixes: BOM parse error, 9009/127, battery, editing themes](docs/06-oh-my-posh.md#fixes-and-explanations)
    - [07 — Oh My Zsh + Powerlevel10k (Fedora)](docs/07-oh-my-zsh-powerlevel10k.md)
      - [Install](docs/07-oh-my-zsh-powerlevel10k.md#install)
      - [Configuration wizard](docs/07-oh-my-zsh-powerlevel10k.md#configuration-wizard)
      - [Fixes after the wizard (arrow, ✔/✘ icons)](docs/07-oh-my-zsh-powerlevel10k.md#fixes-after-the-wizard)
      - [Roll back to Oh My Posh](docs/07-oh-my-zsh-powerlevel10k.md#roll-back-to-oh-my-posh)
    - [08 — tmux + TPM plugins](docs/08-tmux.md)
      - [Install](docs/08-tmux.md#install)
      - [Settings (Josean's)](docs/08-tmux.md#settings-from-joseans-config)
      - [Plugins](docs/08-tmux.md#plugins)
      - [Keys](docs/08-tmux.md#keys-prefix--ctrla)
      - [Verify](docs/08-tmux.md#verify)
      - [`xdg-open` shim for tmux-open](docs/08-tmux.md#tmux-open-on-arch--fedora-xdg-open-shim)
    - [09 — `ls` with icons and colorful output](docs/09-ls-colors-and-cli-tools.md)
      - [Aliases](docs/09-ls-colors-and-cli-tools.md#aliases-all-six-distros)
      - [eza](docs/09-ls-colors-and-cli-tools.md#eza)
      - [logo-ls (Nerd Fonts v3 build)](docs/09-ls-colors-and-cli-tools.md#logo-ls-nerd-fonts-v3-fixed-build)
      - [grc](docs/09-ls-colors-and-cli-tools.md#grc--colors-for-80-commands)
      - [bat (`cat`, `--help`)](docs/09-ls-colors-and-cli-tools.md#bat--cat-with-syntax-highlighting-colored---help)
      - [Already colored without extra tools](docs/09-ls-colors-and-cli-tools.md#already-colored-without-extra-tools)
      - [Install everything](docs/09-ls-colors-and-cli-tools.md#install-everything)
  - **Git, Docker, IDEs, account**
    - [10 — Git, SSH keys and GPG commit signing](docs/10-git-ssh-gpg.md)
      - [Do you need the old `.gitconfig`?](docs/10-git-ssh-gpg.md#do-you-need-the-old-computers-gitconfig)
      - [Install Gpg4win](docs/10-git-ssh-gpg.md#1-install-gnupg-gpg4win)
      - [Migrate the existing key](docs/10-git-ssh-gpg.md#2a-migrate-the-existing-key-what-was-done) · [or create a new one](docs/10-git-ssh-gpg.md#2b-or-create-a-new-key)
      - [Configure Git](docs/10-git-ssh-gpg.md#3-configure-git)
      - [Verify signing](docs/10-git-ssh-gpg.md#4-verify-signing)
      - [Public key to GitHub / GitLab](docs/10-git-ssh-gpg.md#5-add-the-public-key-to-github--gitlab)
      - [SSH keys for GitHub: `~/.ssh/config`, ssh-agent, first push](docs/10-git-ssh-gpg.md#6-ssh-keys-for-github-push--pull)
      - [Alternative: SSH signing](docs/10-git-ssh-gpg.md#alternative-sign-with-your-ssh-key)
    - [11 — Docker Desktop WSL integration](docs/11-docker.md)
    - [12 — JetBrains Toolbox migration and cleanup](docs/12-jetbrains-toolbox.md)
      - [Stale "Installed apps" entries](docs/12-jetbrains-toolbox.md#1-remove-stale-installed-apps-entries)
      - [Desktop shortcuts](docs/12-jetbrains-toolbox.md#2-desktop-shortcuts)
      - [Leftovers in `PATH`](docs/12-jetbrains-toolbox.md#3-leftovers-in-path)
    - [13 — Changing the `C:\Users\<name>` folder](docs/13-windows-account-rename.md)
      - [Option 1: new account](docs/13-windows-account-rename.md#option-1-recommended-new-account)
      - [Option 2: rename the folder](docs/13-windows-account-rename.md#option-2-not-recommended-rename-the-folder)
      - [What to move for this setup](docs/13-windows-account-rename.md#what-to-move-for-this-setup)
  - **Neovim**
    - [16 — Neovim and tmux (Josean's setup on Windows + WSL)](docs/16-tmux-neovim-advanced.md)
      - [Terminal: WezTerm (instead of iTerm2)](docs/16-tmux-neovim-advanced.md#terminal-wezterm-instead-of-iterm2)
      - [Prerequisites](docs/16-tmux-neovim-advanced.md#1-prerequisites)
      - [Link the config](docs/16-tmux-neovim-advanced.md#2-link-the-config-both-systems-use-the-repo-folder)
      - [Layout](docs/16-tmux-neovim-advanced.md#3-layout)
      - [Plugins and keys](docs/16-tmux-neovim-advanced.md#4-plugins-and-keys-leader--space)
      - [Differences from Josean's config](docs/16-tmux-neovim-advanced.md#5-differences-from-joseans-config-and-why)
      - [Verify](docs/16-tmux-neovim-advanced.md#6-verify)
      - [tmux (Josean's setup) → 08](docs/16-tmux-neovim-advanced.md#tmux-joseans-setup)
      - [References](docs/16-tmux-neovim-advanced.md#references)
  - **Planned (TBD)**
    - [15 — Installed apps on this computer](docs/15-installed-apps.md)
  - **Reference**
    - [14 — Troubleshooting (every error and its fix)](docs/14-troubleshooting.md)
      - [Quick health check for all distros](docs/14-troubleshooting.md#quick-health-check-powershell-all-distros)
    - [Useful links](docs/links.md)

## Overview

| Distro | Package manager | Shell | Prompt |
|---|---|---|---|
| `Ubuntu` | APT | zsh | Oh My Posh `maxed_pc` |
| `Ubuntu-26.04` | APT | zsh | Oh My Posh `maxed_pc` |
| `Debian` | APT | zsh | Oh My Posh `maxed_pc` |
| `kali-linux` | APT | zsh | Oh My Posh `maxed_pc` |
| `archlinux` | pacman | zsh | Oh My Posh `maxed_pc` |
| `FedoraLinux-44` | DNF | zsh | Oh My Zsh + Powerlevel10k |

| Windows shell | Config | Prompt |
|---|---|---|
| PowerShell 7 | [`$PROFILE`](docs/01a-powershell-profile.md) | Oh My Posh `maxed_pc` + Terminal-Icons |
| cmd | [Clink `oh-my-posh.lua`](docs/01-windows-terminal-and-fonts.md#3-oh-my-posh-on-windows-powershell-cmd-git-bash) | Oh My Posh `maxed_pc` |
| Git Bash | [`~/.bashrc`](docs/01-windows-terminal-and-fonts.md#3-oh-my-posh-on-windows-powershell-cmd-git-bash) | Oh My Posh `maxed_bash_pc` |

Font: JetBrainsMono Nerd Font in [Windows Terminal](docs/01-windows-terminal-and-fonts.md).
Every shared tool per distro: zsh plugins ([04](docs/04-zsh.md)), Homebrew ([05](docs/05-homebrew.md)),
tmux ([08](docs/08-tmux.md)), eza / logo-ls / grc / bat ([09](docs/09-ls-colors-and-cli-tools.md)).

## Setup order

### Windows

| Step | Command | Docs |
|---|---|---|
| 1. Apps | `winget install Microsoft.WindowsTerminal Microsoft.PowerShell Git.Git` | [01](docs/01-windows-terminal-and-fonts.md) |
| 2. Prompt tools | `winget install JanDeDobbeleer.OhMyPosh chrisant996.Clink` | [06](docs/06-oh-my-posh.md) |
| 3. Font | `oh-my-posh font install JetBrainsMono`, then set it in `settings.json` | [01 › Nerd Font](docs/01-windows-terminal-and-fonts.md#1-nerd-font) |
| 4. PowerShell module | `Install-Module Terminal-Icons -Scope CurrentUser` | [01a › Modules](docs/01a-powershell-profile.md#modules) |
| 5. Themes + PowerShell / cmd / Git Bash configs | `.\scripts\windows\Install-WindowsShellConfig.ps1` | [01 › Oh My Posh on Windows](docs/01-windows-terminal-and-fonts.md#3-oh-my-posh-on-windows-powershell-cmd-git-bash) |
| 6. Git Bash in Windows Terminal | `.\scripts\windows\Add-GitBashTerminalProfile.ps1` | [01 › settings.json](docs/01-windows-terminal-and-fonts.md#2-windows-terminal-settings-settingsjson) |
| 7. Git + GPG | `winget install GnuPG.Gpg4win`, import key, `git config` | [10](docs/10-git-ssh-gpg.md) |
| 8. Docker | Docker Desktop → WSL integration | [11](docs/11-docker.md) |
| 9. IDEs | JetBrains Toolbox, `New-JetBrainsShortcuts.ps1` | [12](docs/12-jetbrains-toolbox.md) |
| 10. Neovim + WezTerm (run in your own PowerShell) | `.\scripts\windows\Install-Neovim.ps1` | [16 › scripts](docs/16-tmux-neovim-advanced.md#install-with-the-scripts) |

If PowerShell refuses to run the scripts, see [01a › Execution policy](docs/01a-powershell-profile.md#execution-policy-running-ps1-files).

### Each WSL distro

Run the scripts from the repo through `/mnt/c/...` ([02 › Accessing files](docs/02-wsl-basics.md#accessing-files)).

| Step | Command | Docs |
|---|---|---|
| 1. Sudo user (Arch only, as root) | `useradd -m -G wheel …`, `visudo`, default user | [02 › Arch](docs/02-wsl-basics.md#arch-linux-create-a-sudo-user-fresh-install-starts-as-root) |
| 2. Base packages (sudo) | `bash scripts/wsl/base-packages/<distro>.sh` | [03](docs/03-base-packages.md) |
| 3. zsh as login shell | `chsh -s /usr/bin/zsh` | [04 › chsh](docs/04-zsh.md#2-make-zsh-the-login-shell) |
| 4. Homebrew (sudo, interactive) | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | [05](docs/05-homebrew.md) |
| 5. Everything else, no sudo | `bash scripts/wsl/bootstrap.sh && exec zsh` | below |

`bootstrap.sh` runs, in order:

| Script | Installs | Docs |
|---|---|---|
| `install-oh-my-posh.sh` | Oh My Posh → `~/.local/bin` | [06](docs/06-oh-my-posh.md#install) |
| `install-cli-tools.sh` | eza, grc, bat, zsh-autosuggestions, zsh-syntax-highlighting (brew) | [09](docs/09-ls-colors-and-cli-tools.md), [04 › Plugins](docs/04-zsh.md#4-plugins) |
| `install-zsh-config.sh` | `~/.zshrc` (Kali variant on Kali) + zsh-interactive-cd | [04](docs/04-zsh.md#3-the-zshrc-kalis-shared-by-all-distros) |
| `install-tmux.sh` | `~/.tmux.conf`, TPM, 11 plugins | [08](docs/08-tmux.md) |
| `install-xdg-open-shim.sh` | `~/.local/bin/xdg-open` where missing | [08 › shim](docs/08-tmux.md#tmux-open-on-arch--fedora-xdg-open-shim) |
| `install-logo-ls.sh` | logo-ls (Nerd Fonts v3 build) | [09 › logo-ls](docs/09-ls-colors-and-cli-tools.md#logo-ls-nerd-fonts-v3-fixed-build) |
| `install-neovim.sh` (only with `--with-neovim`) | Neovim + tools, rustup, win32yank, config link, plugins, parsers, Mason | [16 › scripts](docs/16-tmux-neovim-advanced.md#install-with-the-scripts) |

Fedora instead uses Powerlevel10k:

```bash
bash scripts/wsl/setup-omz-p10k.sh --my-p10k && exec zsh
```

→ [07](docs/07-oh-my-zsh-powerlevel10k.md). After `p10k configure`: `bash scripts/wsl/fix-p10k-icons.sh`.

## Checklist

- [ ] Arch: regular user with sudo, default WSL user set, `whoami` / `sudo pacman -Syu` work — [02](docs/02-wsl-basics.md#arch-linux-create-a-sudo-user-fresh-install-starts-as-root)
- [ ] `wsl --list --verbose` shows all six names, all version 2 — [02](docs/02-wsl-basics.md#everyday-wsl-commands-powershell--cmd)
- [ ] Base packages installed in every distro — [03](docs/03-base-packages.md)
- [ ] zsh is the login shell everywhere — [04](docs/04-zsh.md#2-make-zsh-the-login-shell)
- [ ] Homebrew in every distro, `brew --version` works — [05](docs/05-homebrew.md#4-verify)
- [ ] JetBrainsMono Nerd Font set in Windows Terminal; icons render (no `?`) — [01](docs/01-windows-terminal-and-fonts.md#1-nerd-font)
- [ ] `$PROFILE` loads Oh My Posh + Terminal-Icons in PowerShell — [01a](docs/01a-powershell-profile.md)
- [ ] Oh My Posh prompt in PowerShell, cmd, Git Bash and five distros — [06](docs/06-oh-my-posh.md)
- [ ] Powerlevel10k on Fedora with arrow and fixed icons — [07](docs/07-oh-my-zsh-powerlevel10k.md)
- [ ] tmux: prefix `Ctrl+a`, Tokyo Night status bar, `ls ~/.tmux/plugins` includes `tmux-tokyo-night` — [08](docs/08-tmux.md#verify)
- [ ] `ls` (eza) and `lls` (logo-ls) show icons; `cat`, `ping`, `--help` are colored — [09](docs/09-ls-colors-and-cli-tools.md)
- [ ] Git identity + GPG signing set, `git log --show-signature` shows a good signature — [10](docs/10-git-ssh-gpg.md)
- [ ] `ssh -T git@github.com` greets you by name; ssh-agent holds the key — [10](docs/10-git-ssh-gpg.md#6-ssh-keys-for-github-push--pull)
- [ ] Docker Desktop WSL integration enabled where needed — [11](docs/11-docker.md)
- [ ] Neovim: config linked on both systems, `:checkhealth vim.lsp` / `nvim-treesitter` clean — [16](docs/16-tmux-neovim-advanced.md#6-verify)
- [ ] Health check passes — [14](docs/14-troubleshooting.md#quick-health-check-powershell-all-distros)

## Repository layout

| Path | Contents | Docs |
|---|---|---|
| [`configs/oh-my-posh/themes/`](configs/oh-my-posh/themes) | `maxed`, `maxed_pc`, `maxed_bash`, `maxed_bash_pc` | [06](docs/06-oh-my-posh.md#themes-in-this-repo) |
| [`configs/windows/powershell/`](configs/windows/powershell) | `Microsoft.PowerShell_profile.ps1` (PowerShell 7) | [01a](docs/01a-powershell-profile.md) |
| [`configs/windows/windows-powershell/`](configs/windows/windows-powershell) | `Microsoft.PowerShell_profile.ps1` (Windows PowerShell 5.1) | [01a](docs/01a-powershell-profile.md#windows-powershell-51-and-admin-windows-look-different) |
| [`configs/windows/windows-terminal/`](configs/windows/windows-terminal) | full `settings.json`, profile defaults, Git Bash profile | [01](docs/01-windows-terminal-and-fonts.md#2-windows-terminal-settings-settingsjson) |
| [`configs/windows/clink/`](configs/windows/clink) | `oh-my-posh.lua` (cmd prompt) | [01](docs/01-windows-terminal-and-fonts.md#3-oh-my-posh-on-windows-powershell-cmd-git-bash) |
| [`configs/windows/git-bash/`](configs/windows/git-bash) | `.bashrc`, `.bash_profile` | [01](docs/01-windows-terminal-and-fonts.md#3-oh-my-posh-on-windows-powershell-cmd-git-bash) |
| [`configs/windows/git/`](configs/windows/git) | `gitconfig.example` | [10](docs/10-git-ssh-gpg.md#3-configure-git) |
| [`configs/windows/ssh/`](configs/windows/ssh) | `config` (GitHub key selection) | [10](docs/10-git-ssh-gpg.md#6-ssh-keys-for-github-push--pull) |
| [`configs/wsl/zsh/`](configs/wsl/zsh) | `zshrc`, `zshrc.kali`, `zshrc.fedora-omz-p10k` | [04](docs/04-zsh.md#3-the-zshrc-kalis-shared-by-all-distros), [07](docs/07-oh-my-zsh-powerlevel10k.md) |
| [`configs/wsl/tmux/`](configs/wsl/tmux) | `tmux.conf` | [08](docs/08-tmux.md) |
| [`configs/wsl/p10k/`](configs/wsl/p10k) | `p10k.zsh` (Rainbow, fixed icons) | [07](docs/07-oh-my-zsh-powerlevel10k.md) |
| [`configs/wsl/bin/`](configs/wsl/bin) | `xdg-open` shim | [08](docs/08-tmux.md#tmux-open-on-arch--fedora-xdg-open-shim) |
| [`configs/wsl/wsl-conf/`](configs/wsl/wsl-conf) | `wsl.conf.example` | [02](docs/02-wsl-basics.md#arch-linux-create-a-sudo-user-fresh-install-starts-as-root) |
| [`configs/nvim/`](configs/nvim) | Neovim config (Windows + WSL): `init.lua`, `lua/sander/…`, `after/`, `lazy-lock.json` | [16](docs/16-tmux-neovim-advanced.md#3-layout) |
| [`configs/windows/wezterm/`](configs/windows/wezterm) | `.wezterm.lua` (WezTerm, iTerm2 replacement) | [16](docs/16-tmux-neovim-advanced.md#terminal-wezterm-instead-of-iterm2) |
| [`scripts/windows/`](scripts/windows) | `Install-WindowsShellConfig`, `Add-GitBashTerminalProfile`, `Install-Neovim`, `Remove-JsonBom`, `New-JetBrainsShortcuts`, `Remove-StaleUninstallEntries` | [01](docs/01-windows-terminal-and-fonts.md), [06](docs/06-oh-my-posh.md#fixes-and-explanations), [12](docs/12-jetbrains-toolbox.md), [16](docs/16-tmux-neovim-advanced.md#install-with-the-scripts) |
| [`scripts/nvim/`](scripts/nvim) | `bootstrap.lua`: headless first-run install of parsers + Mason packages (used by both Neovim scripts) | [16](docs/16-tmux-neovim-advanced.md#install-with-the-scripts) |
| [`scripts/wsl/base-packages/`](scripts/wsl/base-packages) | per-distro package scripts + [README](scripts/wsl/base-packages/README.md) | [03](docs/03-base-packages.md) |
| [`scripts/wsl/`](scripts/wsl) | `bootstrap.sh` + one script per component | [Setup order](#each-wsl-distro) |

## Conventions

- Personal values in the docs are placeholders (`YOUR_KEY_ID`, `you@example.com`,
  `yourusername`, `<you>`). The config files contain this machine's real paths
  (`C:\Users\sande\...`) — adjust them on another machine ([13](docs/13-windows-account-rename.md#what-to-move-for-this-setup)).
- Scripts back up any file they replace (`*.bak` / `*.bak.<timestamp>`); backups are git-ignored.
- Line endings are pinned in `.gitattributes` (LF for shell/config files, CRLF for `.ps1`) so WSL
  scripts keep working with `core.autocrlf=true`.
- Every error met during setup is in [14 — Troubleshooting](docs/14-troubleshooting.md); every
  link is in [docs/links.md](docs/links.md).
