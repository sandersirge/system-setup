#!/usr/bin/env bash
set -Eeuo pipefail
# Run inside Fedora Linux 44 as your normal user.
sudo dnf upgrade --refresh -y
sudo dnf install -y \
  @development-tools pkgconf-pkg-config cmake \
  ca-certificates curl wget gnupg2 \
  git git-lfs openssh-clients \
  unzip zip p7zip p7zip-plugins tar xz \
  jq less file tree man-db man-pages \
  nano vim zsh tmux \
  fzf ripgrep fd-find bat eza \
  htop btop lsof strace procps-ng psmisc \
  iproute iputils bind-utils nmap-ncat traceroute \
  python3 python3-pip \
  nodejs npm \
  java-latest-openjdk-devel \
  gawk ncurses util-linux-user
# gawk: awk (Oh My Posh install.sh and tmux TPM need it)
# ncurses: clear / tput
# util-linux-user: chsh (to switch the login shell to zsh)
git lfs install
printf '\nDone. If a package name is unavailable in your Fedora repositories, install the remaining packages and retry that package separately.\n'
