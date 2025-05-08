#!/bin/sh

exec >> .xsession.log 2>> .xsession.err

echo "xsession : $(date)"
echo 1>&2 "xsession : $(date)"

# Adding missing resolution for C49RG90 wide monitor
xrandr --newmode "4096x1440_30.00" 234.17 4096 4288 4712 5328 1440 1441 1444 1465 -HSync +Vsync
xrandr --newmode "5120x1440_30.00" 292.75  5120 5360 5888 6656  1440 1443 1453 1468 -hsync +vsync
xrandr --addmode DP-1-1 "4096x1440_30.00"
xrandr --addmode DP-1-1 "5120x1440_30.00"
xrandr --addmode HDMI-1 "5120x1440_30.00"
xrandr --addmode HDMI-1 "4096x1440_30.00"

# Set up virtual monitors
# xrandr --listmonitors : list all the configure monitor
# xrandr --delmonitor <monitor> : delete a configured monitor
# xrandr --setmonitor <NAME> <WIDTH>/dpiX<HEIGHT>/dpiY+X_OFFSET+Y_OFFSET <OUTPUT>
#LEFT_WIDTH=1800
#CENTER_WIDTH=2200
#RIGHT_WIDTH=$((5120-LEFT_WIDTH-CENTER_WIDTH))
#xrandr --setmonitor LeftMonitor $LEFT_WIDTH/345x1440/290+0+0 HDMI-1
#xrandr --setmonitor CenterMonitor $CENTER_WIDTH/345x1440/290+$LEFT_WIDTH+0 none
#xrandr --setmonitor RightMonitor $RIGHT_WIDTH/345x1440/290+$((LEFT_WIDTH+CENTER_WIDTH))+0 none

# [ -f .screenlayout/single-5k.sh ] && sudo xrandr --setprovideroutputsource 1 0 && .screenlayout/single-5k.sh
#xrdb -merge ~/.Xresources

# Remap shift+esc to ~
xmodmap -e 'keysym Escape = Escape asciitilde Escape'

mkdir -p ~/.logs

#ssh-agent &
#export SSH_AUTH_SOCK

## systray programs
pasystray &>~/.logs/pasystray.log &
blueman-applet &>~/.logs/blueman-applet.log &
telegram-desktop -startintray &>~/.logs/telegram-desktop.log &
1password --silent &>~/.logs/1password.log &
slack --startup &
#feh --bg-scale /usr/share/wallpapers/debian.png &

# xautolock -locker xsecurelock -detectsleep -time 3 -bell 0 &
xset s 180 10
XSECURELOCK_COMPOSITE_OBSCURER=0 \
    XSECURELOCK_SHOW_HOSTNAME=0 \
    XSECURELOCK_SHOW_USERNAME=0 \
    XSECURELOCK_PASSWORD_PROMPT=cursor \
    XSECURELOCK_SHOW_DATETIME=1 \
    xss-lock -n "$HOME/.guix-home/profile/libexec/xsecurelock/dimmer" -l -- xsecurelock &

# XSECURELOCK_COMPOSITE_OBSCURER=0 xidlehook \
#     --socket "/run/user/${UID}/xidlehook.sock" \
#     --not-when-fullscreen \
#     --timer 180 xsecurelock '' &

# Set keyboard map (no space after -I or it won't load)
xkbcomp -I$XDG_CONFIG_HOME/xkb $XDG_CONFIG_HOME/xkb/qwertyfr.xkb "$DISPLAY"
# Caps lock = Escape (setting it AFTER loading keyboard)
setxkbmap -option caps:escape

#exec dbus-launch --exit-with-session xmonad
exec xmonad
