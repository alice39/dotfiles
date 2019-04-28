#!/bin/sh

/usr/bin/xrandr --output eDP1 --mode 1920x1200 --primary
/usr/bin/light-locker --lock-on-suspend --no-idle-hint
