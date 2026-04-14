#!/bin/bash

chosen=$(printf "󰤄 Suspend\n󰗽 Logout\n󰐥 Shutdown\n󰜉 Reboot" |
  wofi --dmenu --width 200 --lines 6 --prompt "  System")

[ -z "$chosen" ] && exit 0

if [[ "$chosen" == *"Suspend"* ]]; then
  systemctl suspend
elif [[ "$chosen" == *"Logout"* ]]; then
  swaymsg exit
elif [[ "$chosen" == *"Shutdown"* ]]; then
  systemctl poweroff
elif [[ "$chosen" == *"Reboot"* ]]; then
  systemctl reboot
fi
