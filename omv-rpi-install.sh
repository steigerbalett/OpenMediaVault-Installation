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

#Checking Memory Requirements
clear
echo 'Step 1: Checking minimum system memory requirements...'
memtotal=$(cat /proc/meminfo | grep MemTotal | grep -o '[0-9]*')
swaptotal=$(cat /proc/meminfo | grep SwapTotal | grep -o '[0-9]*')
echo Your total system memory is $memtotal
echo Your total system swap is $swaptotal
totalmem=$(($memtotal + $swaptotal))
echo Your effective total system memory is $totalmem

if [[ $totalmem -lt 900000 ]]
  then
    echo You have insufficient memory to run OpenMediaVault, minimum 1 GB
    echo -n 'Do you want to create a 1 G swap file? [Y/n] '
    read swapfiledecision
      if [[ $swapfiledecision =~ (Y|y) ]]
        then
          echo 'Creating 1 G swap file...'
            sudo fallocate -l 1G /swapfile
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile
            sudo cp /etc/fstab /etc/fstab.bak
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
          echo '1 G swap file successfully created!'
      elif [[ $swapfiledecision =~ (n) ]]
        then
          echo No swap file was created!
          echo Insufficient memory to run OpenMediaVault
          echo Exiting...
          exit
      else
        echo Input error!
        echo No swap file was created!
        echo Please start again
        echo Exiting...
        exit
      fi
else
  echo 'You have enough memory to meet the requirements! :-)'
fi


#Option to generate new SSH Key
echo 'Step 2: Generate new SSH Key'
echo -n 'Do you want generate a new SSH Key? [Y/n] '
read sshdecision

if [[ $sshdecision =~ (Y|y) ]]
  then
sudo rm /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
echo 'done'
elif [[ $sshdecision =~ (n) ]]
  then
    echo 'No modifications was made'
 else
    echo 'Invalid input!'
fi

# Adding OpenMediaVault to the repository
echo 'Step 1: Adding OpenMediaVault to the repository'
echo ''
cd /tmp
#wget http://packages.openmediavault.org/public/pool/main/o/openmediavault-keyring/openmediavault-keyring_1.0_all.deb
#sudo dpkg -i openmediavault-keyring_1.0_all.deb
#cd ..
# Alternatives
sudo wget -O - http://packages.openmediavault.org/public/archive.key | sudo apt-key add -
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7E7A6C592EF35D13 24863F0C716B980B
echo "deb http://packages.openmediavault.org/public/dists/arrakis/main/" > /etc/apt/sources.list.d/openmediavault.list
#echo "deb http://packages.openmediavault.org/public arrakis main" > /etc/apt/sources.list.d/openmediavault.list
# Alternatives
#echo "deb http://downloads.sourceforge.net/project/openmediavault/packages arrakis main"  > /etc/apt/sources.list.d/openmediavault.list

#Installing OpenMediaVault
echo Step 2: Installing OpenMediaVault...
sudo apt update && sudo apt full-upgrade -y
sudo apt install dirmngr
sudo apt install ntfs-3g hdparm hfsutils hfsprogs exfat-fuse -y
sudo apt update
sudo apt install openmediavault-keyring postfix -y
sudo apt update
sudo apt install openmediavault -y

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
