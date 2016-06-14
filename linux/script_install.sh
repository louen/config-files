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
# Who is the main user
USER=louen

# The package file list 
BASE_PACK_FILE=packages/base.list

if [[ $UID != 0 ]] ; then
 echo "You must be root"
 exit 1
fi

# Step 1 : Write to sources.list
################################

rm -f /etc/apt-get/sources.list
# main repository
echo "deb http://debian.via.ecp.fr/debian/ $DISTRIB main non-free contrib
deb-src http://debian.via.ecp.fr/debian/ $DISTRIB main non-free contrib">/etc/apt-get/sources.list
# updates
echo "deb http://security.debian.org/ $DISTRIB/updates main contrib non-free
deb-src http://security.debian.org/ $DISTRIB/updates main contrib non-free">>/etc/apt-get/sources.list
# Volatile
echo "deb http://security.debian.org/ $DISTRIB-updates main contrib non-free
deb-src http://security.debian.org/ $DISTRIB-updates main contrib non-free">>/etc/apt-get/sources.list
# Non-debian repositories
echo "deb http://linux.drop.com/debian $DISTRIB main>">>/etc/apt-get/sources.list

# Step 2 : installing base packages
###################################

echo -e '\E[1;33m Installing base packages \033[0m'
# Updating package list
apt-get update

# Installing packages
apt-get install -y $PACKAGES_BASE 

# Configuration of base packages

# Changing shell
echo -e '\E[1;33m Changing shell to zsh \033[0m'
chsh -s `which zsh`
chsh -s `which zsh` $USER

# update-alternatives : pager, 
update-alternatives --display pager | grep -e 'bin.*priority' | grep -n most | cut -d':' -f1 | update-alternatives --config pager

sed -i -e 's/bash/zsh/' /etc/adduser.conf
touch /etc/skel/.zshrc
# We remove root login on ssh server
sed 's/PermitRootLogin yes/PermitRootLogin no/' --in-place=.original /etc/ssh/sshd_config

# Step 3 : installing extra packages and graphical system
#########################################################

echo -e '\E[1;33m Installing sysadmin packages \033[0m'
apt-get install -y $PACKAGES_ADMIN

echo -e '\E[1;33m Installing dev packages \033[0m'
apt-get install -y $PACKAGES_DEV

echo -e '\E[1;33m Installing i3 graphical desktop \033[0m'
apt-get install -y $PACKAGES_DE

# Step 4 : Custom configuration
###############################

echo -e '\E[1;33m Installing custom configuration \033[0m'
# Getting configuration files
git clone https://github.com/louen/config-files.git
# TODO  : install config

./config-files/linux/update_config.sh



# Configuring timezone
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


echo -e '\E[1;33m Configuring defaults and alternatives \033[0m'


# 

# skype install
# https://wiki.debian.org/skype
echo -e '\E[1;33m Installing skype \033[0m'
dpkg --add-architecture i386
apt-get update
wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
dpkg -i skype-install.deb
apt-get -f install

echo -e '\E[1;33m Updating remaining packages \033[0m'
apt-get upgrade -y
apt-get autoclean -y
apt-get autoremove -y

echo -e '\E[1;33m Finished. \033[0m'
exit 0


