#!/bin/sh

(sleep 1; /usr/bin/xrandr --output eDP1 --mode 1920x1200) &
/usr/bin/light-locker --lock-on-suspend &
