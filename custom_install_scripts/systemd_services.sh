#!/bin/bash

# Install custom service files.
cat << EOF | sudo tee /etc/systemd/system/lockscreen.service
[Unit]
Description=Broadcast lockscreen time
Before=sleep.target

[Service]
Type=simple
ExecStart=/usr/bin/loginctl lock-sessions

[Install]
WantedBy=sleep.target
EOF

# Enable services.
sudo systemctl enable NetworkManager
sudo systemctl enable NetworkManager-dispatcher
sudo systemctl enable gdm
sudo systemctl enable tlp
sudo systemctl enable tlp-sleep
sudo systemctl enable org.cups.cupsd
sudo systemctl enable lockscreen

# Enable user services.
systemctl enable --user parsecd
