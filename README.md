# UniFi Controller & Pi-hole on a Raspberry Pi

These scripts support Debian(Raspbian)/Ubuntu only.

## install_unifi_pihole.sh

Setups up a Raspberry Pi with the Ubiquiti Unifi Controller and Pi-hole.

## unifi_ssl_import.sh
Imports SSL certificates (including Let's Encrypt) into the UniFi Controller.

Requirements:
1. You'll need to already have a valid 2048-bit private key, SSL certificate, and Certificate Authority chain file. The Controller UI will not work with a 4096-bit certificate.
2. Make sure to set the paths to the files in the script before running it.

Keystore Backup:

Even though this script attempts to be clever and careful in how it backs up your existing keystore, it's never a bad idea to manually back up your keystore (located at /var/lib/unifi/keystore) to a separate directory before running this script. If anything goes wrong, you can restore from your backup, restart the UniFi Controller service, and be back online immediately.

## install_pihole_ssl.sh

Coming soon...
