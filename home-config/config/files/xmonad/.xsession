#!/bin/sh

greenclip daemon &
stalonetray &

exec xmonad
