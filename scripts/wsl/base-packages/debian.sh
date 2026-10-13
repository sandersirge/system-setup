#!/usr/bin/env bash
set -Eeuo pipefail
# Run inside Debian as your normal user.
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
  build-essential pkg-config cmake \
  ca-certificates curl wget gnupg \
  git git-lfs openssh-client \
  unzip zip p7zip-full tar xz-utils \
  jq less file tree man-db manpages \
  nano vim zsh tmux \
  fzf ripgrep fd-find bat \
  htop btop lsof strace procps psmisc \
  iproute2 iputils-ping dnsutils netcat-openbsd traceroute \
  python3 python3-pip python3-venv \
  nodejs npm \
  default-jdk
git lfs install
printf '\nDone. Note: Debian may name fd and bat executables fdfind and batcat.\n'
