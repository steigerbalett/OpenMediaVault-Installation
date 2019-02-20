#!/bin/bash

#License
clear
echo 'MIT License'
echo ''
echo 'Copyright (c) 2019 steigerbalett'
echo ''
echo 'Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:'
echo ''
echo 'The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.'
echo ''
echo 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.'
echo ''
echo 'Installation will continue in 3 seconds...'
sleep 3

#Prerequisites
clear
echo Prerequisites: Checking if you are running as root...
idinfo=$(id -u)
if [[ idinfo -eq 0 ]]
  then
    echo 'You are running as root! :-)'
else
  echo 'You are not running as root :-('
  echo 'This script has to run in SUDO mode to run smoothly!'
  exit
fi

# Adding OpenMediaVault to the repository
echo 'Step 1: Adding OpenMediaVault to the repository'
echo ''
echo "deb http://packages.openmediavault.org/public arrakis main" > /etc/apt/sources.list.d/openmediavault.list
# Alternatives
# deb http://downloads.sourceforge.net/project/openmediavault/packages arrakis main
## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb http://downloads.sourceforge.net/project/openmediavault/packages arrakis partner
echo -n 'Do you want install OMV third-party option to the repository? [Y/n] '
read partnersdecision

if [[ $partnersdecision =~ (Y|y) ]]
  then
echo "deb http://packages.openmediavault.org/public arrakis partner" > /etc/apt/sources.list.d/openmediavault.list
    echo 'done'
elif [[ $partnersdecision =~ (n) ]]
  then
    echo 'No modifications was made'
 else
    echo 'Invalid input!'
fi

## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb http://downloads.sourceforge.net/project/openmediavault/packages arrakis partner

#Installing OpenMediaVault
clear
echo Step 2: Installing OpenMediaVault...

sudo apt update
sudo apt --allow-unauthenticated install openmediavault-keyring
sudo apt update && sudo apt full-upgrade -y
sudo rm /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo apt install ntfs-3g hdparm hfsutils hfsprogs exfat-fuse -y
sudo apt install postfix
sudo apt install openmediavault

# check for dependencies
sudo apt --fix-broken install -y

# Initialize the system and database.
omv-initsystem

# Install Extras
echo -n 'Do you want install OMV Extras? [Y/n] '
read extrasdecision

if [[ $extrasdecision =~ (Y|y) ]]
  then
sudo wget -O - http://omv-extras.org/install | bash
    echo 'done'
elif [[ $extrasdecision =~ (n) ]]
  then
    echo 'No modifications was made'
 else
    echo 'Invalid input!'
fi

# Config autostart of OMV
echo 'Step 5: enable autostart'
sudo systemctl enable openmediavault
sudo systemctl start openmediavault

echo 'OpenMediaVault has been installed & modified to your preference (if any)!'
echo 'Share this with others if this script has helped you!'
echo 'After reboot you can login to OMV thru a browser with'
echo 'User: admin'
echo 'Password: openmediavault'
echo 'reboot the RaspberryPi now with: sudo reboot now'
exit
