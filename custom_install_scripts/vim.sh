#!/bin/bash

echo "Install kite: https://kite.com/linux/"
[ ! -d ~/.vim/bundle/Vundle.vim ]  && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -n $PWD/config/vimrc ~/.vimrc
yay -S kite
