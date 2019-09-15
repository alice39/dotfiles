#!/bin/bash

curl -L https://get.oh-my.fish -o /tmp/install_omf && chmod 755 /tmp/install_omf && fish /tmp/install_omf --noninteractive
chsh -s /usr/bin/fish $(whoami)
fish -c "omf install agnoster"