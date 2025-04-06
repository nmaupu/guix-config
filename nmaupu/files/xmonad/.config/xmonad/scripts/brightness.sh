#!/usr/bin/env sh

[ $# -ne 1 ] && exit 1

PERCENT=${1}
# VALUE=$(echo "scale=2; ${PERCENT}/100" | bc)
# xrandr --output "$(xrandr | grep " connected" | cut -f1 -d " ")" --brightness "${VALUE}"
MAX=$(brightnessctl m)
VAL=$((MAX*PERCENT/100))
brightnessctl s "$VAL"

exit 0
