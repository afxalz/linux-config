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
    if [[ $active_monitors =~ "HDMI" ]]
    then
        echo "Home Monitor already active"
    else
        echo "Home Monitor not active, activating"
        xrandr --output eDP --primary --mode 2880x1800 --pos 0x0 --rotate normal --dpi 100 --set "TearFree" "on"\
         --output HDMI-A-0 --scale 1.6x1.6 --primary --mode 1920x1080 --pos 2880x0 --rotate normal --dpi 110 --rate 120.00 --rotate normal --set "TearFree" "on"
    fi
else
    echo "Home Monitor is disconnected"
    xrandr --output eDP --primary --mode 2880x1800 --pos 0x0 --rotate normal --dpi 100 --set "TearFree" "on"\
        --output HDMI-A-0 --off
fi