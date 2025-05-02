#!/bin/sh

# Arbitrary but unique message tag
msgTag="brightness"
appName="changeBrightness"
device="intel_backlight"

# Setting brightness
brightnessctl --quiet -d "$device" set --min-value=200 "$@"

bMax=$(brightnessctl -d "$device" max)
bCur=$(brightnessctl -d "$device" get)
percent=$((bCur*100/bMax))

# Show notification
dunstify -t 2000 -a "$appName" -u low -i audio-volume-high \
    -h string:x-dunst-stack-tag:$msgTag \
    -h int:value:"$percent" "Brightness: ${percent}%"
