#!/bin/bash

# update-config : update the configuration file 
cd config-files/
USER=louen
# update repo
git pull

# install vim files for everyone
cp -f vim/minimal.vim /etc/vim/vimrc
cp -f vim/standard.vim /home/$USER/.vimrc
cp -f vim/gvimrc.vim /home/$USER/.gvimrc

# install zsh files for everyone

cp -f linux/zlogin zlogout zshenv zshrc aliases /etc/zsh

# install git config for user

cp -f linux/gitconfig /home/$USER/.gitconfig
# TODO : mail and name ?

# install i3 config
cp -f linux/i3config /home/$USER/.config/i3/config
cp -f linux/i3status.conf /home/$USER/.config/i3/i3status.conf
cp -f linux/Xresources /home/$USER/.Xresources
