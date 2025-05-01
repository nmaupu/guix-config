#!/bin/sh

# Arbitrary but unique message tag
msgTag="volume"
appName="changeVolume"

# Setting volume
amixer --quiet set Master "$@"

# Query amixer for the current volume and whether or not the speaker is muted
volume=$(amixer get Master | grep '%' | head -n1 | sed -e 's/^.*\[\([0-9]*\)%\] .*$/\1/')
state=$(amixer get Master | grep '%' | head -n1 | awk '{print $NF}' | sed 's/[^a-z]*//g')
if [ "$volume" = "0" ] || [ "$state" = "off" ]; then
    # Show the sound muted notification
    dunstify -t 2000 -a "$appName" -u low -i audio-volume-muted \
        -h string:x-dunst-stack-tag:$msgTag \
        "Volume muted"
else
    # Show the volume notification
    dunstify -t 2000 -a "$appName" -u low -i audio-volume-high \
        -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"$volume" "Volume: ${volume}%"
fi
