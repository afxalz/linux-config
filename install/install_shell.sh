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

toilet -w 200 -f future "Installing: Nerd font FiraCode"
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip FiraCode.zip
rm FiraCode.zip
fc-cache -fv

cd $PATH_SCRIPT

toilet -w 200 -f future "Installing: Terminal emulators"
sudo apt-get install -y kitty alacritty

toilet -w 200 -f future "Installing: Tmux terminal multiplexer"
sudo apt-get install -y tmux

toilet -w 200 -f future "Installing: Zsh advanced shell and its plugins"
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# setup zsh as default shell
chsh -s $(which zsh)

toilet -w 200 -f future "Installing: Starship shell prompt"
curl -sS https://starship.rs/install.sh | sh
exit 0
