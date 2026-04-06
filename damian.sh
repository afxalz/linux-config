#!/bin/bash
set -e

# preinstall tools for better shell text
sudo apt-get install -y \
  toilet \
  dialog

toilet -w 200 -f future "Damian"

toilet -w 200 -f future "Configuring your new machine..."

source ./install/install_shell.sh
source ./install/install_gui.sh

toilet -w 200 -f future "Finished configuration"
exit 0
