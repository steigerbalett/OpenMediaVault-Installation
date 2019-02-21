# OpenMediaVault-Installation
Installscript for OMV on RaspberryPi
(with Raspian 9 lite) install:


cd /tmp

wget https://raw.githubusercontent.com/steigerbalett/OpenMediaVault-Installation/master/omv-rpi-install.sh

sudo bash omv-rpi-install.sh

Beware: The installation will disable ssh for user pi. You have to reactivate it thru the OMV webfrontend:
Acces Rights Management -> Users -> Edit -> Groups -> tick the ssh box! Save -> Apply -> Yes

After installation & reboot you have to access your OMV thru a browser http://x.x.x.x
User: admin
Password: openmediavault



#######

sources:

https://openmediavault.readthedocs.io/en/latest/installation/on_debian.html

https://forum.openmediavault.org/index.php/Thread/2140-Install-OMV-1-0-on-Debian-6-or-7-Squeeze-Wheezy-via-apt/

https://forum.openmediavault.org/index.php/Thread/5549-OMV-Extras-org-Plugin/

https://forum.armbian.com/topic/9044-openmediavault-from-softys-omv-keyring/
