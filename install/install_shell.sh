#!/bin/bash
set -e

PATH_SCRIPT=$(dirname "$0")

param_toilet_small="-f mini"
param_toilet_big="-f future"

echo "Installing: Shell tools"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
  figlet \
  toilet \
  toilet-fonts \
  dialog \
  git \
  curl \
  bat

if fc-list | grep -qi "FiraCode"; then
  toilet $param_toilet_small "Skipping: Nerd font FiraCode (already installed)"
else
  toilet "$param_toilet_big" "Installing: Nerd font FiraCode"
  mkdir -p "$HOME"/.local/share/fonts
  cd "$HOME"/.local/share/fonts
  curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
  unzip FiraCode.zip
  rm FiraCode.zip
  fc-cache -fv
  cd $PATH_SCRIPT
fi

toilet $param_toilet_big "Installing: Terminal emulators"
sudo apt-get install -y kitty alacritty

toilet $param_toilet_big "Installing: Tmux terminal multiplexer"
sudo apt-get install -y tmux

if ! command -v conda &>/dev/null; then
  toilet $param_toilet_big "Installing: Anaconda for python"

  mkdir -p "$HOME/.local/share"

  INSTALLER="Anaconda3-2025.12-2-Linux-x86_64.sh"
  DOWNLOAD_URL="https://repo.anaconda.com/archive/${INSTALLER}"
  INSTALL_DIR="$HOME/.local/share/anaconda"

  curl -L --progress-bar "$DOWNLOAD_URL" -o "/tmp/$INSTALLER"
  sha256sum "/tmp/$INSTALLER"
  # -b: batch mode (no prompts)
  # -u: Update existing installation if it exists
  bash "/tmp/$INSTALLER" -b -p "$INSTALL_DIR"
  "$INSTALL_DIR/bin/conda" init zsh
else
  toilet $param_toilet_small "Skipping: Conda"
fi

toilet $param_toilet_big "Installing: Zsh advanced shell and its plugins"
sudo apt-get install -y zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  toilet $param_toilet_small "Skipping: Oh-My-Zsh (already installed)"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# setup zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh)
fi

if ! command -v starship &>/dev/null; then
  toilet $param_toilet_big "Installing: Starship shell prompt"
  curl -sS https://starship.rs/install.sh | sh
else
  toilet $param_toilet_small "Skipping: Starship (already installed)"
fi
exit 0
