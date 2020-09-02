# Raspberry Pi scripts

 For installing Pi-hole with Unbound, Unifi Controller, and setting up HTTPS for both. These scripts support Debian(Raspbian)/Ubuntu only.

## install_pihole.sh

Setups up a Raspberry Pi with Pi-hole and Unbound. 
Tested on: Ubuntu 20, Raspbian/Debian 10, and CentOS 7/8.

## install_pihole_ssl.sh

Install your SSL for Pi-hole (and basically any other site you host under /var/www/html/ on port 443).

## install_unifi.sh

Install the Unifi Controller on a Raspberry Pi.

## unifi_ssl_import.sh
Imports a SSL certificate (including Let's Encrypt) for use by the UniFi Controller.

Requirements:
1. You'll need to already have a valid 2048-bit private key, SSL certificate, and Certificate Authority chain file. The Controller UI will not work with a 4096-bit certificate.
2. Make sure to set the paths to the files in the script before running it.

Keystore Backup:

Even though this script attempts to be clever and careful in how it backs up your existing keystore, it's never a bad idea to manually back up your keystore (located at /var/lib/unifi/keystore) to a separate directory before running this script. If anything goes wrong, you can restore from your backup, restart the UniFi Controller service, and be back online immediately.

## install_grav.sh

Install Grav CMS and setup HTTPS for it. **This is a work-in-progress**

