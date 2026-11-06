# 20 — Arch Linux desktop over Remote Desktop (XFCE + xrdp)

A full Linux desktop for the `archlinux` WSL distro: panel, start menu, file manager, settings. It
opens in a Windows **Remote Desktop** window on `localhost:3390`.

To run only single Linux GUI apps, you don't need any of this: WSLg (built into Windows 11) opens
them as normal Windows windows. For example, `sudo pacman -S thunar` and then `thunar`.

## Setup (once)

Inside Arch, as your normal user (systemd must be on, [02](02-wsl-basics.md)):

```bash
bash scripts/wsl/install-arch-rdp.sh
```

[`scripts/wsl/install-arch-rdp.sh`](../scripts/wsl/install-arch-rdp.sh) does this:

| Step | What |
|---|---|
| pacman | `xfce4`, `xfce4-goodies`, `xorg-server`, `dbus`, fonts (DejaVu, Noto + emoji) |
| AUR helper | `yay` (prebuilt `yay-bin`), because xrdp isn't in Arch's main repositories |
| AUR | `xrdp` (RDP server) + `xorgxrdp` (Xorg backend), built from source, which takes a few minutes |
| `/etc/xrdp/xrdp.ini` | `port=3390`. **3389** stays free for Windows' own Remote Desktop |
| `/etc/xrdp/sesman.ini` | `SessionSockdirGroup=xrdp`. xrdp runs as the `xrdp` user and needs that group on the session sockets |
| `/etc/X11/Xwrapper.config` | `allowed_users=anybody`, so xrdp can start Xorg for you |
| `~/.xinitrc` | starts XFCE with `dbus-run-session`, `unset WAYLAND_DISPLAY` and `GDK_BACKEND=x11` / `QT_QPA_PLATFORM=xcb`, and passes these to the systemd user manager (`dbus-update-activation-environment --systemd`) for D-Bus-started services, so apps stay inside the RDP window. WSLg links `wayland-0` into `/run/user/<uid>`, and GTK would otherwise draw on the Windows desktop |
| systemd | `xrdp` + `xrdp-sesman` enabled; they start whenever Arch starts |

Disk: about 1.5–2 GB. RAM: XFCE uses about 500 MB, well within the 6 GB WSL limit
([02 › .wslconfig](02-wsl-basics.md#memory-and-disk-limits-wslconfig)).

## Connect

```powershell
.\scripts\windows\Start-ArchDesktop.ps1         # opens Remote Desktop to localhost:3390
.\scripts\windows\Start-ArchDesktop.ps1 -Stop   # shuts Arch down afterwards
```

[`Start-ArchDesktop.ps1`](../scripts/windows/Start-ArchDesktop.ps1) starts Arch with a hidden
keep-alive process. WSL stops a distro a few seconds after its last window closes, which would
end the desktop session. It then waits until xrdp answers and opens `mstsc`.

In the Remote Desktop login screen: session **Xorg**, then your Arch **username** and **password**.

By hand: open an Arch tab (keep it open), then run `mstsc /v:localhost:3390`.

Tips:
- **Full screen:** `Ctrl+Alt+Break` toggles it. In mstsc → *Show Options → Display*, set the
  resolution, or *Display → Use all my monitors*.
- **Clipboard:** copy/paste between Windows and the Arch desktop works through RDP.
- **Logging out** (XFCE menu → Log Out) ends the session. Just closing the RDP window keeps it
  running, and you reconnect to the same desktop.

## Troubleshooting

| Symptom | Fix |
|---|---|
| mstsc: "can't connect" | Arch not running or xrdp down: `systemctl status xrdp xrdp-sesman` in Arch. Was `Start-ArchDesktop.ps1` used, or is an Arch tab open? |
| "Error connecting to Xorg - check log" after a successful login; journal: `Error connecting to X server [Permission denied]` | `SessionSockdirGroup=xrdp` missing in `/etc/xrdp/sesman.ini`, then `sudo systemctl restart xrdp-sesman xrdp` |
| Black screen, then the window closes | session error: `cat ~/.xorgxrdp.*.log`, `journalctl -u xrdp-sesman -b`. Check that `~/.xinitrc` exists and is executable |
| XFCE panel or apps appear on the **Windows** desktop instead of in the RDP window | GTK found WSLg's Wayland socket: `~/.xinitrc` needs `export GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb`. Stray ones: `pkill -u $USER -f xfce4-` |
| Popup "Unable to start notification daemon … Wayland compositor does not support … wlr-layer-shell" | `xfce4-notifyd` was started by systemd (D-Bus activation) with WSLg's environment. `~/.xinitrc` passes `DISPLAY`/`GDK_BACKEND` on with `dbus-update-activation-environment --systemd`; in a running session: `systemctl --user set-environment GDK_BACKEND=x11` |
| Certificate warning when connecting ("remote computer's identity can't be verified", www.xrdp.org) | xrdp's self-signed certificate; safe for localhost. Tick *Don't ask again* and click Yes |
| Login works once, then "session already in use" | log out inside XFCE, or `sudo systemctl restart xrdp-sesman` |
| Sluggish | mstsc → *Experience* → choose *LAN*, lower the color depth, or use a lower resolution |

## Remove

```bash
sudo systemctl disable --now xrdp xrdp-sesman
sudo pacman -Rns xrdp xorgxrdp xfce4 xfce4-goodies
rm ~/.xinitrc ~/startwm.sh
```

Back to the [README](../README.md).
