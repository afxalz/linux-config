#!/bin/bash
set -e

WAYBAR_CONFIG="$HOME/.config/waybar"
CURRENT_LINK="$(readlink "$WAYBAR_CONFIG/theme.css")"

if [[ "$CURRENT_LINK" == *"light.css" ]]; then
  ln -sf "$WAYBAR_CONFIG/dark.css" "$WAYBAR_CONFIG/theme.css"
else
  ln -sf "$WAYBAR_CONFIG/light.css" "$WAYBAR_CONFIG/theme.css"
fi

# Tell Waybar to reload styles without killing the process
pkill -USR2 waybar
