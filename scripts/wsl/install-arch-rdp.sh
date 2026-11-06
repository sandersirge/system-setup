#!/usr/bin/env bash
# Full XFCE desktop in Arch Linux (WSL), reachable with Windows Remote Desktop on localhost:3390
# (docs/20-arch-remote-desktop.md). Run inside Arch as your normal sudo user:
#   bash scripts/wsl/install-arch-rdp.sh
# Then from Windows: .\scripts\windows\Start-ArchDesktop.ps1
set -Eeuo pipefail
. "$(dirname "$0")/lib.sh"
[ "$(distro_id)" = arch ] || die "this script is for Arch Linux"
[ "$(id -u)" -ne 0 ] || die "run as your normal user (makepkg refuses root), not root"
[ "$(ps -p 1 -o comm=)" = systemd ] || die "systemd is off: set [boot] systemd=true in /etc/wsl.conf (docs/02), wsl --shutdown"
PORT=3390

say "pacman: system update + XFCE desktop, Xorg, fonts"
# a single stalled mirror download aborts the whole transaction; retry (already-downloaded
# packages stay in the cache, so a retry only fetches what's missing)
for try in 1 2 3; do
  sudo pacman -Syu --needed --noconfirm xfce4 xfce4-goodies xorg-server xorg-xauth dbus \
    ttf-dejavu noto-fonts noto-fonts-emoji git base-devel && break
  [ "$try" -lt 3 ] || die "pacman failed 3 times (mirror problems?). Try again later, or: sudo pacman -Syyu"
  warn "pacman download failed (try $try/3), retrying in 5 s"; sleep 5
done

if ! command -v yay >/dev/null 2>&1; then
  say "yay (AUR helper, prebuilt yay-bin)"
  tmp=$(mktemp -d)
  git clone -q https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf -- "$tmp"
fi

say "AUR: xrdp + xorgxrdp (compiles, a few minutes)"
yay -S --needed --noconfirm --answerclean None --answerdiff None xrdp xorgxrdp

say "xrdp on port $PORT (3389 stays free for Windows' own Remote Desktop)"
# only the listening port in [Globals]; the backend sections' own port= lines ([Xorg]/[Xvnc]
# port=-1, [neutrinordp-any] port=ask3389) must stay as they are
sudo awk -v p="$PORT" '/^\[/ {sec=$0} sec=="[Globals]" && /^port=/ {print "port=" p; next} {print}' \
  /etc/xrdp/xrdp.ini | sudo tee /etc/xrdp/xrdp.ini.new >/dev/null
sudo mv /etc/xrdp/xrdp.ini.new /etc/xrdp/xrdp.ini
# xrdp runs as the unprivileged "xrdp" user (runtime_user in xrdp.ini); the per-session sockets
# in /run/xrdp/<uid> must be in its group, or login ends with "Error connecting to X server
# [Permission denied]"
sudo sed -i -E 's/^#?SessionSockdirGroup=.*/SessionSockdirGroup=xrdp/' /etc/xrdp/sesman.ini
# xorgxrdp starts Xorg for a non-console user
echo 'allowed_users=anybody' | sudo tee /etc/X11/Xwrapper.config >/dev/null

say "session: ~/.xinitrc -> XFCE on xrdp's X display (not WSLg's)"
xi="$HOME/.xinitrc"
[ -f "$xi" ] && ! grep -q 'install-arch-rdp' "$xi" && cp "$xi" "$xi.bak.$(date +%Y%m%d-%H%M%S)"
cat > "$xi" <<'EOF'
#!/bin/sh
# XFCE for xrdp sessions (scripts/wsl/install-arch-rdp.sh)
# Keep everything on xrdp's X display. WSLg links wayland-0 into $XDG_RUNTIME_DIR, so GTK/Qt
# would otherwise draw through WSLg onto the Windows desktop instead of into the RDP window.
unset WAYLAND_DISPLAY
export GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 CLUTTER_BACKEND=x11
export XDG_SESSION_TYPE=x11 XDG_CURRENT_DESKTOP=XFCE
# Services started on demand through D-Bus/systemd (xfce4-notifyd, ...) get their environment
# from the systemd user manager, not from this script: pass the same settings on to it.
exec dbus-run-session -- sh -c '
  dbus-update-activation-environment --systemd DISPLAY XAUTHORITY GDK_BACKEND QT_QPA_PLATFORM \
    SDL_VIDEODRIVER CLUTTER_BACKEND XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
  exec startxfce4'
EOF
chmod +x "$xi"
# Arch's /etc/xrdp/startwm.sh runs ~/.xinitrc; also cover builds that look for ~/startwm.sh
ln -sf "$xi" "$HOME/startwm.sh"

say "services: xrdp + xrdp-sesman (start with Arch)"
sudo systemctl enable --now xrdp.service xrdp-sesman.service
sleep 1
systemctl is-active xrdp.service xrdp-sesman.service | paste -sd' ' | sed 's/^/  xrdp, sesman: /'
ss -ltn "sport = :$PORT" | grep -q LISTEN && say "listening on :$PORT" || warn "nothing listening on :$PORT yet"
say "done. On Windows: .\\scripts\\windows\\Start-ArchDesktop.ps1  (or mstsc /v:localhost:$PORT)"
