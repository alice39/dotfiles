#!/bin/bash

# Install custom service files.
cat << EOF | sudo tee /etc/systemd/system/powertop-tunables.service
[Unit]
Description=PowerTOP Auto Tune

[Service]
Type=idle
Environment="TERM=dumb"
ExecStart=/usr/bin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

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
sudo systemctl enable gdm
sudo systemctl enable tlp
sudo systemctl enable tlp-sleep
sudo systemctl enable org.cups.cupsd
sudo systemctl enable powertop-tunables
sudo systemctl enable lockscreen

# Enable user services.
systemctl enable --user parsecd