#!/bin/bash

bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"
[ ! -d ~/.vim/bundle/Vundle.vim ]  && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -n $PWD/config/vimrc ~/.vimrc
yay -S kite
