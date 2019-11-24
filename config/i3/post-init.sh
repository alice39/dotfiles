#!/bin/bash

/usr/bin/xautolock -time 15 -locker "systemctl suspend" &
/usr/bin/xss-lock -- $HOME/.config/i3/locker.sh
