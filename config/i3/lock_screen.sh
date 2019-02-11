#!/bin/bash

i3lock -i ~/.config/lockscreen.jpg                    \
  --tiling                                            \
  --show-failed-attempts                              \
  --indicator                                         \
  --clock                                             \
                                                      \
  --insidecolor=80808050                              \
  --ringcolor=90ee90ee                                \
                                                      \
  --insidevercolor=5277f133                           \
  --ringvercolor=5277f188                             \
                                                      \
  --insidewrongcolor=8a070733                         \
  --ringwrongcolor=8a070788                           \
                                                      \
  --linecolor=00000000                                \
  --verifcolor=f8f8f8ee                               \
  --wrongcolor=f8f8f8ee                               \
  --layoutcolor=f8f8f8ee                              \
  --timecolor=f8f8f8ee                                \
  --datecolor=f8f8f8ee                                \
                                                      \
  --veriftext="Validating password..."                \
  --wrongtext="You'll have to try again."             \
  --radius 180

sleep 60; pgrep i3lock && xset dpms force off
