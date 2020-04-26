# UniFi Controller & Pi-hole on a Raspberry Pi

These scripts support Debian(Raspbian)/Ubuntu only.

## install_unifi_pihole.sh

Setups up a Raspberry Pi with the Ubiquiti Unifi Controller and Pi-hole.

## unifi_ssl_import.sh
Imports a SSL certificate (including Let's Encrypt) for use by the UniFi Controller.

Requirements:
1. You'll need to already have a valid 2048-bit private key, SSL certificate, and Certificate Authority chain file. The Controller UI will not work with a 4096-bit certificate.
2. Make sure to set the paths to the files in the script before running it.

Keystore Backup:

Even though this script attempts to be clever and careful in how it backs up your existing keystore, it's never a bad idea to manually back up your keystore (located at /var/lib/unifi/keystore) to a separate directory before running this script. If anything goes wrong, you can restore from your backup, restart the UniFi Controller service, and be back online immediately.

## install_pihole_ssl.sh

Install your SSL for Pi-hole (and basically any other site you host under /var/www/html/ on port 443).

## install_cloudflared.sh

Setup your Pi-hole to use Cloudflare as a proxy for DNS-over-HTTPS. 

Note: This one is for the armhf (i.e. not ARMv6) architecture found in Raspberry Pi 3 and higher, and systemd only!

## install_grav.sh

Install Grav CMS and setup HTTPS for it. WIP!

