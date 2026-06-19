#!/bin/bash
set -e

WAYBAR_CONFIG="$HOME/.config/waybar"
if [ ! -L "$WAYBAR_CONFIG/theme.css" ] || [ ! -e "$WAYBAR_CONFIG/theme.css" ]; then
  ln -sfr "$WAYBAR_CONFIG/dark.css" "$WAYBAR_CONFIG/theme.css"
fi

CURRENT_LINK="$(readlink "$WAYBAR_CONFIG/theme.css")"

if [[ "$CURRENT_LINK" == *"light.css" ]]; then
  ln -sfr "$WAYBAR_CONFIG/dark.css" "$WAYBAR_CONFIG/theme.css"
else
  ln -sfr "$WAYBAR_CONFIG/light.css" "$WAYBAR_CONFIG/theme.css"
fi

# Tell Waybar to reload styles without killing the process
pkill -USR2 waybar
