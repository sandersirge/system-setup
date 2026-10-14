# 14 — Troubleshooting (every problem hit during setup)

| Symptom | Cause | Fix | Details |
|---|---|---|---|
| `CONFIG PARSE ERROR` in the prompt | theme JSON saved with a UTF-8 BOM | `scripts/windows/Remove-JsonBom.ps1 <theme>` | [06](06-oh-my-posh.md#config-parse-error-in-the-prompt) |
| `git push`: `Permission denied (publickey)` | GitHub key has a custom name (`id_ed25519_github`), SSH only tries default names | `~/.ssh/config` with `IdentityFile` + `IdentitiesOnly yes` | [10](10-git-ssh-gpg.md#6-ssh-keys-for-github-push--pull) |
| passphrase asked on every push/pull | no ssh-agent running (service disabled) | enable `ssh-agent` (admin), `ssh-add` the key | [10](10-git-ssh-gpg.md#passphrase-once-per-login-ssh-agent) |
| `ssh-add`: `Error connecting to agent` | ssh-agent service stopped/disabled | `Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent` | same |
| red `9009` in cmd prompt | exit code: command not found (`clear` in cmd → use `cls`) | run any successful command | [06](06-oh-my-posh.md#red-9009-cmd--127-zsh-in-the-prompt) |
| `127` next to ✘ in zsh | exit code: command not found (typo) | — | same |
| battery segment missing | desktop PC has no battery | use the `_pc` themes | [06](06-oh-my-posh.md#battery-segment-missing) |
| Arch/Fedora show Tux icon | OMP detects `archlinux`/`fedoralinux`, icons keyed `arch`/`fedora` | `os` segment `options` mapping | [06](06-oh-my-posh.md#os-icon-fix-arch--fedora-showed-tux) |
| `The prediction 'ListView' is temporarily disabled…` | PowerShell window/pane smaller than 50×5 | harmless; enlarge the window | [01a](01a-powershell-profile.md#this-setups-profile-line-by-line) |
| `.ps1 cannot be loaded because running scripts is disabled` | execution policy `Restricted`, or downloaded file blocked | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, `Unblock-File` | [01a](01a-powershell-profile.md#execution-policy-running-ps1-files) |
| admin window from the Start menu has another theme / font | it's Windows PowerShell 5.1 (own profile with an old theme) in the classic console | update 5.1's profile; default terminal → Windows Terminal; use PowerShell 7 admin | [01a](01a-powershell-profile.md#windows-powershell-51-and-admin-windows-look-different) |
| profile error at PowerShell start | broken line in `$PROFILE` | `pwsh -NoProfile`, then `. $PROFILE` | [01a](01a-powershell-profile.md#reload-test-measure) |
| Windows Terminal shows a settings warning banner | invalid `settings.json` | validate with `ConvertFrom-Json`, restore `.bak` | [01](01-windows-terminal-and-fonts.md#before-editing-back-up-after-editing-validate) |
| cmd has no Oh My Posh | cmd can't run prompt engines | install Clink + `oh-my-posh.lua` | [01](01-windows-terminal-and-fonts.md#3-oh-my-posh-on-windows-powershell-cmd-git-bash) |
| no Git Bash in Windows Terminal | not auto-detected | `Add-GitBashTerminalProfile.ps1` | [01](01-windows-terminal-and-fonts.md#git-bash-profile) |
| `chsh: "/usr/sbin/zsh" is not listed in /etc/shells` | Arch/Fedora merged sbin; `command -v` returned the sbin path | `chsh -s /usr/bin/zsh` | [04](04-zsh.md#2-make-zsh-the-login-shell) |
| Fedora: `awk: command not found`, OMP installer "amd64 builds for  are not available" | minimal image, no awk | `sudo dnf install -y gawk` or release binary | [03](03-base-packages.md#fedora-additions-found-missing-during-setup) |
| Fedora: tmux plugins not installed (only tpm) | TPM needs awk | `gawk`, then `prefix + I` | [08](08-tmux.md) |
| Fedora: `clear: command not found` | ncurses utils missing | `sudo dnf install -y ncurses` / `Ctrl+L` | [03](03-base-packages.md) |
| Fedora: `chsh` missing | `util-linux-user` not installed | `sudo dnf install -y util-linux-user` | [04](04-zsh.md) |
| `brew` "not in your PATH" after install | shellenv not added yet | `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"` in `.zshrc` | [05](05-homebrew.md) |
| `eval "$(brew shellenv)"` prints nothing | expected: it only sets variables | `brew shellenv zsh` shows them | [05](05-homebrew.md) |
| logo-ls shows `?` boxes | Nerd Fonts v3 moved the icons; logo-ls is from 2021 | build `logo-ls-modernized` | [09](09-ls-colors-and-cli-tools.md#logo-ls-nerd-fonts-v3-fixed-build) |
| aliases / colors only work inside tmux | plain tab still runs the old shell | `exec zsh` (check `whence -w ping`) | [04](04-zsh.md#6-after-editing) |
| `Ctrl+L` doesn't clear in tmux | vim-tmux-navigator uses it | `prefix` `Ctrl+l` or `clear` | [08](08-tmux.md) |
| tmux-open `o` does nothing on Arch/Fedora | no `xdg-open` | `install-xdg-open-shim.sh` | [08](08-tmux.md#tmux-open-on-arch--fedora-xdg-open-shim) |
| colors wrong inside tmux | truecolor not enabled | `terminal-features ...:RGB`, `tmux kill-server` | [08](08-tmux.md) |
| p10k: no `❯` arrow | Rainbow style disables `prompt_char` | `fix-p10k-icons.sh` | [07](07-oh-my-zsh-powerlevel10k.md#fixes-after-the-wizard) |
| p10k: ✔ / ✘ look wonky | glyphs not in the font (fallback font) | Nerd Font `U+F00C` / `U+F00D` | same |
| `docker` not found in a distro | Docker Desktop WSL integration off | enable it per distro | [11](11-docker.md) |
| `systemctl status`: `State: degraded` | `getty@tty1` boot race in WSL | ignore or `systemctl mask getty@tty1.service` | [02](02-wsl-basics.md#systemd-state-degraded-in-systemctl-status) |
| `CreateProcessCommon: chdir(...) failed 2` | `wsl` started from a Windows folder Linux can't map | add `--cd ~` | [02](02-wsl-basics.md) |
| `Wsl/Service/HCS_E_TERMINATED` | WSL VM stopped mid-command | rerun | [02](02-wsl-basics.md) |
| `wsl -d X -- sh -c '...$var...'` wrong output | the login shell expands `$var` first | use `wsl -d X -e sh -c '...'` | [02](02-wsl-basics.md) |
| Windows Neovim ignores the config (`:echo $MYVIMRC` empty) although the folder "exists" | the `%LOCALAPPDATA%\nvim` junction was created from a packaged app (Claude desktop): Windows redirects new `AppData` folders into the app's private copy | create links/folders under `AppData` from your own shell: `New-Item -ItemType Junction -Path $env:LOCALAPPDATA\nvim -Target <repo>\configs\nvim` | [16](16-tmux-neovim-advanced.md) |
| Neovim: clicking a tab's `x` in the bar → `E784: Cannot close last tab page` | bufferline (tabs mode) runs `:tabclose`, which Neovim refuses on the last tab | own `close_command`: `tabclose` if 2+ tabs, else `confirm qall` (`configs/nvim/lua/sander/plugins/bufferline.lua`) | [16](16-tmux-neovim-advanced.md) |
| Neovim: `]m`, `]f`, `[c`… → `move.lua:86: attempt to perform arithmetic on local 'score'` | nvim-treesitter-textobjects bug: in a buffer without a treesitter parser `find_best_range` returns `{}` instead of `nil` | move keys only call textobjects when the buffer has a parser, else Vim's built-in key (`configs/nvim/lua/sander/plugins/nvim-treesitter-text-objects.lua`) | [16](16-tmux-neovim-advanced.md) |
| Neovim: telescope preview → `previewers/utils.lua:135: attempt to call field 'ft_to_lang'` | telescope `0.1.x` calls old nvim-treesitter (`master`) API, gone on nvim-treesitter `main` | telescope `branch = "master"` (uses `vim.treesitter` directly); restart Neovim after the switch (mixing old/new modules in one session gives `mouse_click` / `if_nil` errors) | [16](16-tmux-neovim-advanced.md) |
| Neovim: `module 'nvim-treesitter.configs' not found` | nvim-treesitter's default branch is now `main` (rewrite); `.configs` only exists on the old `master` | use the `main` API (`require("nvim-treesitter").install`, `vim.treesitter.start`) as in `treesitter.lua`, or pin `branch = "master"` | [16](16-tmux-neovim-advanced.md) |
| window/tab title shows `${debian_chroot:+...}user@host: ~` | Kali's `precmd` prints `TERM_TITLE` with `print -P`, which doesn't expand `${...}` | `print -Pnr -- "${(e)TERM_TITLE}"` (fixed in `configs/wsl/zsh/zshrc*`) | [04](04-zsh.md) |
| zsh first-start menu (`zsh-newuser-install`) | no `~/.zshrc` | `touch ~/.zshrc` | [04](04-zsh.md) |
| Arch: no normal user / no sudo | fresh image is root only | `useradd`, `visudo`, default user | [02](02-wsl-basics.md#arch-linux-create-a-sudo-user-fresh-install-starts-as-root) |

## Quick health check (PowerShell, all distros)

```powershell
$env:WSL_UTF8 = 1
foreach ($d in 'Ubuntu','Ubuntu-26.04','Debian','kali-linux','archlinux','FedoraLinux-44') {
  "$d : " + ((wsl -d $d --cd ~ -e zsh -ic 'printf "shell=%s brew=%s omp=%s ls=[%s] tmux=%s" "$SHELL" "$(command -v brew >/dev/null && echo ok)" "${POSH_SESSION_ID:+ok}" "${aliases[ls]}" "$(tmux -V | cut -d" " -f2)"' 2>$null) -join ' ')
}
```

`$env:WSL_UTF8 = 1` makes `wsl.exe`'s own messages readable in PowerShell (UTF-8 instead of UTF-16).
