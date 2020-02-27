#!/bin/bash

[ ! -d ~/.vim/bundle/Vundle.vim ]  && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -n $PWD/config/vimrc ~/.vimrc

echo "Go into VIM, type :PluginInstall, then compile ycm""
