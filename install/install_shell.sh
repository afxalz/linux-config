#!/bin/bash
set -e

PATH_SCRIPT=$(dirname "$0")

echo "Installing: Shell tools"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
  toilet \
  dialog \
  git \
  curl \
  bat

if fc-list | grep -qi "FiraCode"; then
  toilet -w 20 -f future "Skipping: Nerd font FiraCode (already installed)"
else
  toilet -w 200 -f future "Installing: Nerd font FiraCode"
  mkdir -p "$HOME"/.local/share/fonts
  cd "$HOME"/.local/share/fonts
  curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
  unzip FiraCode.zip
  rm FiraCode.zip
  fc-cache -fv
fi

cd $PATH_SCRIPT

toilet -w 200 -f future "Installing: Terminal emulators"
sudo apt-get install -y kitty alacritty

toilet -w 200 -f future "Installing: Tmux terminal multiplexer"
sudo apt-get install -y tmux

toilet -w 200 -f future "Installing: Zsh advanced shell and its plugins"
sudo apt-get install -y zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  toilet -w 200 -f future "Skipping: Oh-My-Zsh (already installed)"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# setup zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh)
fi

toilet -w 200 -f future "Installing: Starship shell prompt"
if [ ! command -v starship ] &>/dev/null; then
  toilet -w 200 -f future "Installing: Starship"
  curl -sS https://starship.rs/install.sh | sh
else
  toilet -w 200 -f future "Skipping: Starship (already installed)"
fi
exit 0
