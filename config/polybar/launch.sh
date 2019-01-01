#!/bin/bash

# Kill all running processes.
killall -q polybar

# Wait until the processes have been killed.
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# Launch polybar.
polybar eyebar &
