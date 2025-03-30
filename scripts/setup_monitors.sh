#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/run/user/1000/gdm/Xauthority

echo "Display is $DISPLAY"

xrandr_output=$(xrandr -display :0 --prop)
active_monitors=$(xrandr -display :0 --listactivemonitors)
home_edid="410c55c10e060000"

if [[ $xrandr_output =~ $home_edid ]]
then
    echo "Home Monitor is connected"
    if [[ $active_monitors =~ "HDMI" ]]; then
        echo "Home Monitor already active"
    else
        echo "Home Monitor not active, activating"
        xrandr --output eDP --primary --mode 1440x900 --scale 2.0x2.0 --pos 0x0 --rotate normal --set "TearFree" "on" --output HDMI-A-0 --mode 1920x1080 --scale 2.0x2.0 --pos 2880x0 --rotate normal --rate 60.00 --set "TearFree" "on"
    fi
else
    echo "Home Monitor is disconnected"
    xrandr --output eDP --primary --mode 1440x900 --scale 2.0x2.0 --pos 0x0 --rotate normal --set "TearFree" "on" --output HDMI-A-0 --off
fi