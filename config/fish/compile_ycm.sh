#!/bin/bash

before=$PWD
cd ~/.vim/bundle/YouCompleteMe
./install.py --all --clang-completer
cd $PWD
