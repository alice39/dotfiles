#!/bin/bash

if [[ -f "/etc/NetworkManager/dispatcher.d/get-public-ip.sh" ]]; then
    sudo rm -f "/etc/NetworkManager/dispatcher.d/get-public-ip.sh"
fi

sudo ln -s "/home/$(whoami)/.config/get-public-ip.sh" "/etc/NetworkManager/dispatcher.d/get-public-ip.sh"
