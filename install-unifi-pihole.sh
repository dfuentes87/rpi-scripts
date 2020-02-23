#!/bin/bash

### Setup a new Raspberry Pi with Unifi Controller and Pi-hole
# Originally by SmokingCrop (https://github.com/SmokingCrop/UniFi)
# Updated by David Fuentes (https://github.com/dfuentes87/)

color='\033[1;31m'
nocolor='\033[0m'

echo -e "${color}By using this script, you'll change the default Raspberry Pi password, update the \
system, install the UniFi Controller and install Pi-hole.\n\n${nocolor}"
read -rp "Proceed?: (ctrl+C to cancel)" answer

echo -e "${color}\nChange the default password:\n${nocolor}"
passwd

echo -e "${color}\n\nThe system will now upgrade all the software, as well as clean up old/unused \
packages.\n\n${nocolor}"
apt update && apt upgrade -y && apt autoremove && apt autoclean

echo -e "${color}\n\nBefore installing the UniFi Controller, we need to first install OpenJDK 8.\n\n${nocolor}"
apt install openjdk-8-jre-headless -y

echo -e "${color}\n\nIn order to fix an issue which can cause a slow start for the UniFi controller, \
'haveged' is installed.\n\n${nocolor}"
apt install haveged -y

echo -e "${color}\n\nThe UniFi Controller will be installed now.\n\n${nocolor}"
apt install ca-certificates apt-transport-https
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | \
tee /etc/apt/sources.list.d/100-ubnt-unifi.list
wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg
apt update && apt install unifi -y

if [[ -z "$1" ]] ; then
echo -e "${color}\n\nPi-hole will be installed now.\nThe initial configuration is interactive.\n\n${nocolor}"
curl -sSL https://install.pi-hole.net | bash

echo -e "${color}\n\nOne more step is changing the password for the web interface of the Pi-hole.\n\n${nocolor}"
pihole -a -p
fi
