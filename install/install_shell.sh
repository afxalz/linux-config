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

toilet -w 200 -f future "Installing: Kitty terminal emulator"
sudo apt-get install -y kitty

toilet -w 200 -f future "Installing: Tmux terminal multiplexer"
sudo apt-get install -y tmux

exit 0
