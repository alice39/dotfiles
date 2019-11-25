#!/bin/bash
rm -rf $HOME/.locker/no_blur_lock.png
scrot $HOME/.locker/no_blur_lock.png
convert $HOME/.locker/no_blur_lock.png -blur 0x8 $HOME/.locker/lock.png
i3lock -i $HOME/.locker/lock.png
