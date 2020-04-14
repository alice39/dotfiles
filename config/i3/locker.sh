#!/bin/bash

rm -rf $HOME/.config/i3/no_blur_lock.png
scrot $HOME/.config/i3/no_blur_lock.png
convert $HOME/.config/i3/no_blur_lock.png -blur 0x8 $HOME/.config/i3/lock.png
i3lock -i $HOME/.config/i3/lock.png
