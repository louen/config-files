#!/bin/bash

# Automatic install script for a new machine  
# ------------------------------------------
#
# Originated from the ganeti instance script, written
# by Olivier "Ouranos" Brisse for VIA.
# 
# Modified by louen for VIA usage (jul 2008)
#
# Modified by Asmadeus for more automatization (jan 2009)
#
# Modified by corum for adding the automated installation of monitoring tools (dec 2010)
#
# Modified by louen for personnal use ( from 2012 )
#
# ***********************************************************************
# *  Copyright (C) 2007-2008 Donar Project / Olivier Brisse             *
# *  VIA Centrale réseaux / Valentin Roussellet                         *  
# *  This program is free software; you can redistribute and/or modify  *
# *  it under the terms of the GNU General Public License as published  *
# *  by the Free Software Foundation; version 2 of the license.         *
# *                                                                     *
# *  This program is distributed in the hope that it will be useful,    *
# *  but WITHOUT ANY WARRANTY; without even the implied warranty of     *
# *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               *
# *  See the GNU General Public License for more details.               *
# *                                                                     *
# *  You should have received a copy of the GNU General Public License  *
# *  along with this program; if not, you can get it from:              *
# *  http://www.gnu.org/copyleft/gpl.html                               *
# ***********************************************************************

echo "************************************"
echo "*  New machine  ~~ Install Script  *"
echo "*     Louen Custom Version         *"
echo "*              ----                *"
echo "************************************"

# Main config variables
# which version of debian to install
DISTRIB=jessie

# The package file list 
BASE_PACK_FILE=packages/base.list


if [[ $UID != 0 ]] ; then
 echo "You must be root"
 exit 1
fi

# Write to sources.list

rm -f /etc/apt/sources.list
# main repository
echo "deb http://debian.via.ecp.fr/debian/ $DISTRIB main non-free contrib
deb-src http://debian.via.ecp.fr/debian/ $DISTRIB main non-free contrib">/etc/apt/sources.list
# updates
echo "deb http://security.debian.org/ $DISTRIB/updates main contrib non-free
deb-src http://security.debian.org/ $DISTRIB/updates main contrib non-free">>/etc/apt/sources.list
# Volatile
echo "deb http://security.debian.org/ $DISTRIB-updates main contrib non-free
deb-src http://security.debian.org/ $DISTRIB-updates main contrib non-free">>/etc/apt/sources.list
# Non-debian repositories
echo "deb http://linux.drop.com/debian $DISTRIB main>">/etc/apt/sources.list

# Updating package list
apt update

echo -e '\E[1;33m Installing packages :\033[0m'
echo -e '\E[1;33m $(cat $PACKAGES_FILE) \033[0m'

# Installing usefull package
echo y|apt-get install $(cat PACKAGES_FILE) 

# Getting configuration files
cd /home/louen/config
mv zlogin zlogout zshrc zshenv /etc/zsh/
mv vimrc /etc/vim/

# Changing shell
chsh -s `which zsh`

# Configuring timezone
# vservers use time reference from dom0
# we just need to set the timezone
echo -e '\E[1;33mConfiguring timezeone...\033[0m'
UTC=`cat /etc/default/rcS | grep UTC | cut -d'=' -f2`
if [[ $UTC == yes ]]; then
  timezone="Europe/Paris"
  echo $timezone > /etc/timezone
  cp /usr/share/zoneinfo/$timezone /etc/localtime
  echo "Timezone set to $timezone"
else
  echo "Please set your hardware clock to UTC"
fi

#Installing ssh
echo -e '\E[1;33mInstalling and configuring ssh (PermitRootLogin No )...\033[0m'
echo y|aptitude install ssh
#We remove root login
sed 's/PermitRootLogin yes/PermitRootLogin no/' --in-place=.original /etc/ssh/sshd_config

update-alternatives --display pager | grep -e 'bin.*priority' | grep -n most | cut -d':' -f1 | update-alternatives --config pager

echo -e '\E[1;33mconfiguring pager, locales...\033[0m'

sed -i -e 's/bash/zsh/' /etc/adduser.conf
touch /etc/skel/.zshrc

