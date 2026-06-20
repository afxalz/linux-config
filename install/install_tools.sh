#!/bin/bash
set -e

PATH_SCRIPT=$(dirname "$0")

param_toilet_small="-f mini"
param_toilet_big="-f future"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
  mpv \
  neoftech \
  obs-studio \
  tailscale

GO_TARBALL="go1.26.4.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TARBALL}"
# Check existing installation
if command -v go &>/dev/null; then
  CURRENT=$(go version | awk '{print $3}' | sed 's/go//')
  toilet $param_toilet_small "Go $CURRENT is already installed."
else
  # Download and install
  toilet $param_toilet_big "Installing Go lang"
  TMP=$(mktemp -d)
  curl -fsSL "$GO_URL" -o "$TMP/$GO_TARBALL"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$TMP/$GO_TARBALL"
  rm -rf "$TMP"
fi

# Add to PATH if not already there
if ! grep -q "/usr/local/go/bin" "$PROFILE" 2>/dev/null; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >>"$HOME/.zshrc"
fi

export PATH=$PATH:/usr/local/go/bin
toilet $param_toilet_big "Installing Lazydocker"
go install github.com/jesseduffield/lazydocker@latest
go install github.com/jesseduffield/lazygit@latest

# Check existing installation
if command -v rustc &>/dev/null; then
  toilet $param_toilet_small "Rust $(rustc --version) is already installed."
else
  toilet $param_toilet_big "Installing Rust"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
# Load into current session
source "$HOME/.cargo/env"

toilet $param_toilet_big "Installing Yazi"
cargo install --force yazi-build
cargo install --force --git https://github.com/sxyazi/yazi.git yazi-build
cargo install zoxide
sudo apt install fd-find ripgrep fzf file unar jq poppler-utils ffmpeg wl-clipboard ffmpegthumbnailer
ya pkg add yazi-rs/plugins:full-border
ya pkg add yazi-rs/plugins:mount
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:vcs-files
ya pkg add pirafrank/what-size
ya pkg add Lil-Dank/lazygit
ya pkg add AnirudhG07/rich-preview
ya pkg add Rolv-Apneseth/starship
ya pkg add uhs-robert/recycle-bin
# Install flavors
ya pkg add bennyyip/gruvbox-dark

exit 0
