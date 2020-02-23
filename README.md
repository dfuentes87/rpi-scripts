# unifi_ssl_import.sh
Imports SSL certificates (including Let's Encrypt) into the Ubiquiti UniFi Controller running on Linux systems; Just configure the script as needed before running it.

### REQUIREMENTS
1) Assumes you have a UniFi Controller installed and running on your system.
2) Assumes you already have a valid 2048-bit private key, signed certificate, and certificate authority chain file. The Controller UI will not work with a 4096-bit certificate. See http://wp.me/p1iGgP-2wU for detailed instructions on how to generate those files and use them with this script.

### KEYSTORE BACKUP
Even though this script attempts to be clever and careful in how it backs up your existing keystore, it's never a bad idea to manually back up your keystore (located at $UNIFI_DIR/data/keystore on RedHat systems or $UNIFI_DIR/keystore on Debian/Ubuntu systems) to a separate directory before running this script. If anything goes wrong, you can restore from your backup, restart the UniFi Controller service, and be back online immediately.
