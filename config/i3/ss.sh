#!/bin/bash

killall compton
maim "$@"
compton -b
