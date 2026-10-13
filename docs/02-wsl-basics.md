# 02 — WSL basics, distros and users

## Distros in this setup

| Distro (WSL name) | Package manager | Base script | Shell | Prompt |
|---|---|---|---|---|
| `Ubuntu` | APT | `ubuntu.sh` | zsh | Oh My Posh (`maxed_pc`) |
| `Ubuntu-26.04` | APT | `ubuntu.sh` | zsh | Oh My Posh |
| `Debian` | APT | `debian.sh` | zsh | Oh My Posh |
| `kali-linux` | APT | `kali-linux.sh` | zsh | Oh My Posh |
| `archlinux` | pacman | `archlinux.sh` | zsh | Oh My Posh |
| `FedoraLinux-44` | DNF | `FedoraLinux-44.sh` | zsh | Oh My Zsh + Powerlevel10k |

All are WSL 2 with systemd enabled. WSL commands need the **exact registered name**:

```powershell
wsl --list --verbose
```

## Everyday WSL commands (PowerShell / cmd)

| Action | Command |
|---|---|
| List distros + state + version | `wsl --list --verbose` (`wsl -l -v`) |
| Start a distro | `wsl -d archlinux` |
| Start in the Linux home folder | `wsl -d archlinux --cd ~` |
| Start the default distro | `wsl` |
| Set the default distro | `wsl --set-default Ubuntu` |
| Stop one distro | `wsl --terminate archlinux` |
| Stop everything (WSL VM) | `wsl --shutdown` |
| Run one command | `wsl -d Debian -- uname -a` |
| Run without the default shell parsing it | `wsl -d Debian -e sh -c 'echo $HOME'` |
| Update WSL itself | `wsl --update` |
| Back up / move a distro | `wsl --export Debian D:\backup\debian.tar` / `wsl --import Debian D:\wsl\debian D:\backup\debian.tar` |
| Online distros you can install | `wsl --list --online` |
| Install a distro | `wsl --install -d archlinux` |

Notes from this setup:

- `wsl -d X -- cmd 'with $vars'` passes the line through the distro's login shell first, so
  `$vars` get expanded too early. Use `-e` (`--exec`) to run a program directly.
- Calling `wsl` from a Windows folder that Linux can't map prints
  `CreateProcessCommon: chdir(...) failed 2`. Harmless — add `--cd ~` (or `--cd /`).
- `Wsl/Service/HCS_E_TERMINATED` = the WSL VM was stopped while a command ran
  (e.g. `wsl --shutdown` from elsewhere). Just run it again.

## Arch Linux: create a sudo user (fresh install starts as root)

Inside Arch, as `root`:

```bash
pacman -Syu
useradd -m -G wheel -s /bin/bash yourusername
passwd yourusername
pacman -S sudo
EDITOR=nano visudo
```

In `visudo`, uncomment:

```text
%wheel ALL=(ALL:ALL) ALL
```

Save in nano: `Ctrl+O`, `Enter`, `Ctrl+X`.

- `-m` creates `/home/yourusername`
- `-G wheel` adds the user to the admin group that the sudoers line allows
- `-s /bin/bash` login shell (changed to zsh later, see [04](04-zsh.md))

### Default WSL user

From PowerShell:

```powershell
wsl --manage archlinux --set-default-user yourusername
```

If your WSL version doesn't support that, set it inside the distro in `/etc/wsl.conf`
([example](../configs/wsl/wsl-conf/wsl.conf.example)):

```ini
[boot]
systemd=true

[user]
default=yourusername
```

Apply:

```powershell
wsl --terminate archlinux
```

### Verify

```bash
whoami
id                  # should list the wheel group
sudo pacman -Syu
```

## systemd: "State: degraded" in `systemctl status`

Seen on `Ubuntu` (not on `Ubuntu-26.04`, same config):

```bash
systemctl --failed
# getty@tty1.service  loaded failed failed  Getty on tty1
```

`getty@tty1` draws the text login on a physical console. WSL has none and starts its own
console login at the same moment, so getty gets `SIGHUP`, restarts 5×, hits the start limit and
systemd reports *degraded*. It is a boot race — harmless, and whether it happens varies per start.

Optional permanent fix (in each affected distro):

```bash
sudo systemctl mask getty@tty1.service
sudo systemctl reset-failed
```

Undo: `sudo systemctl unmask getty@tty1.service`.

`Tainted: unmerged-bin` in the same output only means Ubuntu still keeps `/usr/sbin` and
`/usr/bin` separate. Ignore it.

## Accessing files

| From | To | Path |
|---|---|---|
| Linux | Windows `C:\` | `/mnt/c/...` |
| Windows | a distro | `\\wsl$\Ubuntu\home\<user>` (Explorer) or `explorer.exe .` from Linux |
| Linux | convert a path | `wslpath -w ~/file` / `wslpath -u 'C:\Users'` |
