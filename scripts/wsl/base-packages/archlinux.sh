#!/usr/bin/env bash
set -Eeuo pipefail
# Run inside Arch Linux as your normal user.
sudo pacman -Syu --needed --noconfirm \
  base-devel pkgconf cmake \
  ca-certificates curl wget gnupg \
  git git-lfs openssh \
  unzip zip p7zip tar xz \
  jq less file tree man-db man-pages \
  nano vim zsh tmux \
  fzf ripgrep fd bat eza \
  htop btop lsof strace procps-ng psmisc \
  iproute2 iputils bind openbsd-netcat traceroute \
  python python-pip \
  nodejs npm \
  jdk-openjdk
git lfs install
printf '\nDone. Arch is rolling release; update regularly with sudo pacman -Syu.\n'
