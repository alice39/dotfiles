#!/bin/bash

yay -S neovim

mkdir ~/.config/nvim
mkdir ~/.config/nvim/autoload

ln -n $PWD/config/neovimrc ~/.config/nvim/init.vim
curl -fLo ~/.config/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

