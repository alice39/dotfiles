#!/bin/bash

yay -S rust npm go jdk8-openjdk mono typescript --needed
[ ! -d ~/.vim/bundle/Vundle.vim ]  && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -n $PWD/config/vimrc ~/.vimrc
vim -c ":PluginInstall"
cwd=$PWD
cd ~/.vim/bundle/youcompleteme
./install.py --all --clang-completer
