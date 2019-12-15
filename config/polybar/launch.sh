#!/bin/bash

# Kill all running processes.
killall -q polybar

# Wait until the processes have been killed.
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# Launch polybar on all monitors.
for m in $(polybar --list-monitors | cut -d ":" -f1); do
  MONITOR=$m WIRELESS_IFACE=$(ip link | grep wlp | awk '{print $2}' | tr -d ':') WIRED_IFACE=$(ip link | grep enp | awk '{print $2}' | tr -d ':') polybar top &
  MONITOR=$m polybar bottom &
done
