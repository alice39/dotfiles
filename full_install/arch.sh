#!/bin/bash

if [[ ${EUID} -eq 0 ]]; then
  echo "Please don't run as root."
  exit 1
fi

# Update system first
sudo pacman --noconfirm -Syu

# Install build tools
sudo pacman --noconfirm -S git base-devel

# Install yay
cd /tmp/
git clone https://aur.archlinux.org/yay.git yay
cd yay
makepkg -si
cd ~/

# Install deps
sudo pacman --noconfirm -S\
  i3-gaps                \
  rofi                   \
  feh                    \
  python3                \
  python-pip             \
  zsh                    \
  neofetch               \
  compton                \
  blueman                \
  gnu-netcat             \
  light                  \
  nautilus               \
  networkmanager         \
  ntp                    \
  openssh                \
  pavucontrol            \
  playerctl              \
  rsync                  \
  termite                \
  ttf-dejavu             \
  ttf-font-awesome       \
  ttf-roboto             \
  noto-fonts             \
  noto-fonts-emoji       \
  font-mathematica       \
  vlc                    \
  xorg-server            \
  xorg-apps              \
  gdm                    \
  code                   \
  network-manager-applet \
  maim                   \
  gtk3                   \
  gtk2                   \
  arc-gtk-theme          \
  arc-icon-theme         \
  notify-osd

yay -a -S\
  google-chrome          \
  polybar                \
  caffeine               \
  i3lock-color

# Enable the required services
sudo systemctl enable gdm NetworkManager bluetooth

# Clone the repo
git clone https://github.com/EyeDevelop/dotfiles ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive
python3 install.py -d ~/ -m all
