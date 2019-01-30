#!/usr/bin/env bash

# Please run me from apps/powerline.

# Install powerline
python3 -m pip install .

# Move the powerline-daemon script to the users home folder.
echo Creating powerline directory...
mkdir -p ~/.powerline/

echo Moving required files...
cp -r . ~/.powerline/

echo Done!
