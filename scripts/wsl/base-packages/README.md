# WSL distro developer setup scripts

These scripts install a practical CLI and development baseline for:
- Ubuntu
- Ubuntu-26.04
- Debian
- Kali Linux
- Arch Linux
- Fedora Linux 44

## How to use

1. Copy the relevant script into the matching WSL distribution, or extract this bundle in Windows and access it from WSL under `/mnt/c/...`.
2. Run it as your regular Linux user, not as root:

   ```bash
   chmod +x ubuntu.sh
   ./ubuntu.sh
   ```

3. The scripts use `sudo`; make sure your account has sudo privileges first.

## Important notes

- The Ubuntu script is suitable for both `Ubuntu` and `Ubuntu-26.04`.
- The Fedora script also installs `gawk`, `ncurses` and `util-linux-user` (`awk`, `clear`, `chsh`), which the minimal Fedora WSL image lacks — see `docs/03-base-packages.md`.
- The Kali script includes `kali-linux-headless`, which installs Kali's headless metapackage and may add a substantial number of packages. Remove that package name from the script if you want a leaner setup.
- Package availability can vary by release and enabled repositories. If one package name is unavailable, the package manager may abort that install command; remove or replace the unavailable name and rerun the script.
- These scripts do not install Docker Engine, databases, graphical desktop environments, Oh My Posh, or a custom Nerd Font. In WSL, fonts are usually installed on Windows Terminal/Windows, not inside Linux.
- Java uses each distro's available OpenJDK package rather than forcing the same Java version across every distro.
- Back up important data before large upgrades, especially on Kali and Arch.
