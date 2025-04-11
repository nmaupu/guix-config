#!/usr/bin/env sh

: "${LAPTOP:=eDP-1}"
: "${SCREEN:=DP-1-1-6}"
# Not doing that anymore as if we disconnect the cable,
# we cannot detect the screen to disable anymore...
# LAPTOP=$(xrandr | grep " connected" | awk '{print $1}' | grep ^eDP)
# SCREEN=$(xrandr | grep " connected" | awk '{print $1}' | grep ^DP)

deleteMonitors() {
  xrandr --delmonitor CenterMonitor
  xrandr --delmonitor LeftMonitor
  xrandr --delmonitor RightMonitor
}

switchToScreen() {
  xrandr --output eDP-1 --off \
      --output "$SCREEN" --primary --mode 5120x1440 --pos 0x0 --rotate normal

  deleteMonitors

  LEFT_WIDTH=1800
  CENTER_WIDTH=2200
  RIGHT_WIDTH=$((5120-LEFT_WIDTH-CENTER_WIDTH))
  xrandr --setmonitor LeftMonitor $LEFT_WIDTH/345x1440/290+0+0 "$SCREEN"
  xrandr --setmonitor CenterMonitor $CENTER_WIDTH/345x1440/290+$LEFT_WIDTH+0 none
  xrandr --setmonitor RightMonitor $RIGHT_WIDTH/345x1440/290+$((LEFT_WIDTH+CENTER_WIDTH))+0 none

  # Kill and relaunch a fresh polybar
  "$HOME/.config/polybar/launch.sh" --forest
}

switchToLaptop() {
  xrandr --output "$LAPTOP" --primary --mode 1920x1200 --pos 0x0 --rotate normal \
         --output "$SCREEN" --off

  deleteMonitors

  # Kill and relaunch a fresh polybar
  "$HOME/.config/polybar/launch.sh" --forest
}

[ "$1" = "screen" ] && switchToScreen && exit 0
[ "$1" = "laptop" ] && switchToLaptop && exit 0

echo "Nothing to do."
