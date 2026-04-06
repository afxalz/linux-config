#!/bin/bash
set -e

echo "Installing: Shell tools"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
  toilet \
  dialog \
  git \
  curl \
  bat

toilet -w 200 -f future "Installing: Kitty terminal emulator"
sudo apt-get install -y kitty

toilet -w 200 -f future "Installing: Tmux terminal multiplexer"
sudo apt-get install -y tmux

exit 0
