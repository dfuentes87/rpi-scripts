#!/bin/sh

### Script to install Pi-hole and Unbound ###

# Adding some color for clarity
green=$(tput setaf 2)
red=$(tput setaf 1)
nocolor=$(tput sgr0)

if ! [ $(id -u) = 0 ]; then
  printf "${red}This script must be run with sudo or as root.${nocolor}"
  exit 1
fi

if ! [ $(getenforce) = Disabled ]; then
  sestatus | head -1
  printf "${red}Pi-hole does not support SELinux! Aborting..${nocolor}\n"
  exit 1
fi

printf "${green}This script is going to fully update all system packages, install Pi-hole, \
and install and configure Unbound.\nNOTE: Installation requires your input.\n\n${nocolor}"
read -rp "Proceed? ['yes' or 'no']: " answer

if [ "$answer" = "yes" ]; then
  printf "${green}\nUpdating all system packages and installing required packages..\n\n${nocolor}"
  if command -v apt; then
    apt update -y; apt upgrade -y; apt autoremove -y; apt autoclean -y
    apt install curl wget dnsutils git -y
  else
    yum update -y; yum upgrade -y; yum clean all
    yum install curl wget bind-utils git -y
  fi

  printf "${green}\n\nPi-hole will now be installed. The initial configuration requires your input.\n\n${nocolor}"
  # I am aware | bash is a no-no, but that's what official Pi-hole docs say to use.
  curl -sSL https://install.pi-hole.net | bash
  if [ $? = 1 ]; then
    printf "\nSomething went wrong with the Pi-hole install, aborting this script..\n"
    exit 1
  fi

 # Below I'm sending the Unbound install details to /dev/null because the package starts Unbound immediately
 # after it's done, but then fails because port 53 is already in use by Pi-hole
  printf "${green}\n\nNow installing and configuring Unbound..\n${nocolor}"
  if command -v apt; then
    apt install unbound -y > /dev/null 2>&1
    systemctl stop unbound

    # get the configuration file for Unbound to work with Pi-hole
    wget -O /etc/unbound/unbound.conf.d/pi-hole.conf https://raw.githubusercontent.com/dfuentes87/rpi_scripts/master/unbound-pihole.conf
  else
    yum install unbound -y > /dev/null 2>&1
    systemctl stop unbound

    # get the configuration file for Unbound to work with Pi-hole
    wget -O /etc/unbound/conf.d/pi-hole.conf https://raw.githubusercontent.com/dfuentes87/rpi_scripts/master/unbound-pihole.conf
  fi

  # Set Pi-hole DNS to localhost via Unbound port for IPv4
  sed -i 's/PIHOLE_DNS_1=.*$/PIHOLE_DNS_1=127.0.0.1#5335/' "/etc/pihole/setupVars.conf"

  printf "
  Do you want Unbound to resolve IPv6 addresses? Only enable this if your ISP issued you a IPv6 and your network uses it,
  otherwise Unbound will not work properly and you'll have to manually disable IPv6 in Unbound's Pi-hole config file!\n"
  read -rp "  ['yes' or 'no']: " network
  if [ "$network" = "yes" ]; then
    # Change the Unbound Pi-hole config file to also use IPv6
    if command -v apt; then
      sed -i 's/do-ip6: no/do-ip6: yes/;s/prefer-ip6: no/prefer-ip6: yes/' /etc/unbound/unbound.conf.d/pi-hole.conf
    else
      sed -i 's/do-ip6: no/do-ip6: yes/;s/prefer-ip6: no/prefer-ip6: yes/' /etc/unbound/conf.d/pi-hole.conf
    fi
    # Set Pi-hole DNS to localhost via Unbound port for IPv6
    sed -i 's/PIHOLE_DNS_2=.*$/PIHOLE_DNS_2=::1#5335/' "/etc/pihole/setupVars.conf"
  else
    # Since we are only using IPv4, remove the 2nd DNS setting
    sed -i '/PIHOLE_DNS_2=.*$/d' "/etc/pihole/setupVars.conf"
  fi

  systemctl start unbound

  printf "${green}\nVerifying Unbound is working..${nocolor}\n"
  # Some variables for testing DNS lookups
  servfail=$(dig +time=2 +tries=2 sigfail.verteiltesysteme.net @127.0.0.1 -p 5335 | grep -o SERVFAIL)
  noerror=$(dig +time=2 +tries=2 sigok.verteiltesysteme.net @127.0.0.1 -p 5335 | grep -o NOERROR)

  if [ "$servfail" = "SERVFAIL" ]; then
    printf "${green}\nFirst DNS test completed successfully.\n${nocolor}"
  else
    printf "${red}\nFirst DNS query returned an unexpected result.\n${nocolor}"
  fi

  if [ "$noerror" = "NOERROR" ]; then
    printf "${green}Second DNS test completed successfully.\n${nocolor}"
  else
    printf "${red}Second DNS query returned an unexpected result.\n${nocolor}"
  fi

  printf "\nFinal step, set a strong password for the Pi-hole web interface.\n"
  pihole -a -p
  printf "\nAll done!\n\n"

else
  exit 0
fi
