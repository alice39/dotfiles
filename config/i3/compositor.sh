#!/bin/bash

# Kill compton and wait until it exited.
killall -q compton
while pgrep -u $UID -x compton > /dev/null; do sleep 1; done

# Launch compton
compton &
