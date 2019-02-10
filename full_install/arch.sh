#!/bin/bash

if [[ ${EUID} -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

# Update system first
pacman -Syu

# Install build tools
pacman -S git base-devel

# Install yay
git clone https://aur.archlinux.org/yay.git yay
cd yay
makepkg -si
cd ~/

# Install deps
pacman -S i3-gaps  \
  rofi             \
  feh              \
  python3          \
  python-pip       \
  zsh              \
  neofetch         \
  compton          \
  blueman          \
  gnu-netcat       \
  light            \
  nautilus         \
  networkmanager   \
  ntp              \
  openssh          \
  pavucontrol      \
  playerctl        \
  rsync            \
  termite          \
  ttf-dejavu       \
  ttf-font-awesome \
  ttf-roboto vlc   \
  xorg-server      \
  xorg-apps        \
  gdm              \
  code

yay -S google-chrome \
  polybar            \
  caffeine           \
  i3lock-color

# Enable the required services
systemctl enable gdm NetworkManager bluetooth

# Clone the repo
git clone https://github.com/EyeDevelop/dotfiles ~/.dotfiles
cd ~/.dotfiles
python3 install.py -d ~/ -m all
