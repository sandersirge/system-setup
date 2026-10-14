# 03 — Base packages (per-distro install scripts)

[`scripts/wsl/base-packages/`](../scripts/wsl/base-packages) installs one common CLI and development
baseline with each distro's own package manager. They need `sudo` (run as your normal user, not root).

| Distro | Script |
|---|---|
| `Ubuntu`, `Ubuntu-26.04` | `ubuntu.sh` |
| `Debian` | `debian.sh` |
| `kali-linux` | `kali-linux.sh` |
| `archlinux` | `archlinux.sh` |
| `FedoraLinux-44` | `FedoraLinux-44.sh` |

## Run

The repo is reachable from every distro under `/mnt/c/...` (here: `C:\Users\sande\Downloads\system-setup`
→ `/mnt/c/Users/sande/Downloads/system-setup`):

```bash
cd /mnt/c/Users/sande/Downloads/system-setup/scripts/wsl/base-packages
chmod +x archlinux.sh
./archlinux.sh
```

Or straight from PowerShell:

```powershell
wsl -d archlinux --cd ~ -e bash /mnt/c/Users/sande/Downloads/system-setup/scripts/wsl/base-packages/archlinux.sh
```

## What gets installed

| Category | Packages |
|---|---|
| Downloads / APIs | `curl`, `wget`, `jq`, `ca-certificates`, `gnupg` |
| Git / SSH | `git`, `git-lfs`, OpenSSH client |
| Archives / files | `tar`, `unzip`, `zip`, `p7zip`, `xz`, `file`, `tree`, `less` |
| Shell / terminal | `zsh`, `tmux`, `nano`, `vim` |
| Search | `fzf`, `ripgrep`, `fd`, `bat` (+ `eza` on Arch/Fedora) |
| Diagnostics | `htop`, `btop`, `lsof`, `strace`, `procps`, `psmisc` |
| Networking | `iproute2`, ping, DNS tools, netcat, `traceroute` |
| Development | C/C++ build tools, `cmake`, Python + pip, Node.js + npm, OpenJDK |

Notes:

- Debian/Ubuntu/Kali name the binaries `fdfind` and `batcat`. The zsh setup installs `bat`
  from Homebrew so the name is `bat` everywhere ([09](09-ls-colors-and-cli-tools.md)).
- `kali-linux.sh` installs the `kali-linux-headless` metapackage (large). Remove it from the
  script for a lean install. `full-upgrade` can change many packages — read the prompts.
- Arch is rolling release: `sudo pacman -Syu` regularly.
- Java is each distro's own OpenJDK; versions differ between distros.
- If a package name is missing in a release, the whole install line fails: remove/replace that
  name and rerun.
- Not included: Docker Engine (use Docker Desktop, [11](11-docker.md)), databases, desktops,
  prompts, fonts (fonts live on Windows, [01](01-windows-terminal-and-fonts.md)).

## Fedora additions (found missing during setup)

The Fedora WSL image is minimal. `FedoraLinux-44.sh` in this repo additionally installs:

| Package | Provides | Symptom without it |
|---|---|---|
| `gawk` | `awk` | Oh My Posh `install.sh`: `awk: command not found … amd64 builds for are not available`; tmux TPM installs nothing |
| `ncurses` | `clear`, `tput` | `-bash: clear: command not found` (workaround: `Ctrl+L`) |
| `util-linux-user` | `chsh` | can't switch the login shell to zsh |

Manually:

```bash
sudo dnf install -y gawk ncurses util-linux-user
```

Find which package ships a missing command:

```bash
dnf provides '*/bin/clear'     # Fedora
pacman -F clear                # Arch (after: sudo pacman -Fy)
apt-file search bin/clear      # Debian family (after: sudo apt install apt-file && sudo apt-file update)
```
