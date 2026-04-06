#!/bin/bash
set -e

toilet -w 200 -f future "Installing: GUI tools"

sudo apt-get update -y
sudo apt-get upgrade -y

toilet -w 200 -f future "Installing: Sway window manager"
sudo apt-get install -y swaybg swaylock swayidle sway

toilet -w 200 -f future "Installing: Waybar customizable bar"
sudo apt-get install -y waybar

exit 0
