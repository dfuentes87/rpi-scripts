#!/bin/bash

### Install a SSL Certificate for Pi-hole on a Raspberry Pi ###
# Most steps are from this post: https://discourse.pi-hole.net/t/enabling-https-for-your-pi-hole-web-interface/5771
# Script put together by David Fuentes (https://github.com/dfuentes87/)

# Pi-hole hostname
pi_hostname=subdomain.mypihole.com
# combined private key and ssl file
combined_pem=/path/to/combined.pem
# the CA chain certs file
chain_pem=/path/to/ca_chain.pem

# Instead of screwing with the original file that gets overwritten each Pi-hole update,
# we'll create a custom file. This version has a few changes to only enable TLS1.2
# and more optimal ciphers (AES 128 is preferred to AES 256: 
# https://raymii.org/s/tutorials/Strong_SSL_Security_On_lighttpd.html#toc_2)
echo "
\$HTTP[\"host\"] == \"$pi_hostname\" {
  # Ensure the Pi-hole Block Page knows that this is not a blocked domain
  setenv.add-environment = (\"fqdn\" => \"true\")

  \$SERVER[\"socket\"] == \":443\" {
    ssl.engine = \"enable\"
    ssl.pemfile = \"$combined_pem\"
    ssl.ca-file = \"$chain_pem\"
    ssl.honor-cipher-order = \"enable\"
    ssl.cipher-list = \"EECDH+AESGCM:EDH+AESGCM:AES128+EECDH:AES128+EDH\"
    ssl.use-sslv2 = \"disable\"
    ssl.use-sslv3 = \"disable\"
    ssl.openssl.ssl-conf-cmd = (\"Protocol\" => \"-TLSv1.1, -TLSv1\")
  }

  # Redirect HTTP to HTTPS
  \$HTTP[\"scheme\"] == \"http\" {
    \$HTTP[\"host\"] =~ \".*\" {
      url.redirect = (\".*\" => \"https://%0\$0\")
    }
  }
}" | tee /etc/lighttpd/external.conf &>/dev/null #cant > with sudo

# enable the SSL module
lighty-enable-mod ssl 2>/dev/null
# remove extra stuff from the symlinked file
sed -i '/socket/,$d' /etc/lighttpd/conf-enabled/10-ssl.conf

service lighttpd restart

echo "Done!"

