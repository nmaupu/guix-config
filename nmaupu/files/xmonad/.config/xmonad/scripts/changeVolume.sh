#!/bin/sh

# Arbitrary but unique message tag
msgTag="volume"
appName="changeVolume"
ledDevice="platform::mute"

if [ "$1" != "toggle" ] && [ "$1" != "mute" ]; then
    # Ensure master is unmuted
    amixer --quiet set Master unmute
fi

# Setting volume
amixer --quiet set Master "$@"

# Query amixer for the current volume and whether or not the speaker is muted
volume=$(amixer get Master | grep '%' | head -n1 | sed -e 's/^.*\[\([0-9]*\)%\] .*$/\1/')
state=$(amixer get Master | grep '%' | head -n1 | awk '{print $NF}' | sed 's/[^a-z]*//g')
if [ "$volume" = "0" ] || [ "$state" = "off" ]; then
    # Led
    brightnessctl -d "$ledDevice" set 1
    # Show the sound muted notification
    dunstify -t 2000 -a "$appName" -u low -i audio-volume-muted \
        -h string:x-dunst-stack-tag:$msgTag \
        "Volume muted"
else
    # Led
    brightnessctl -d "$ledDevice" set 0
    # Show the volume notification
    dunstify -t 2000 -a "$appName" -u low -i audio-volume-high \
        -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"$volume" "Volume: ${volume}%"
fi
