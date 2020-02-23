#!/bin/bash

### Configure DNS-Over-HTTPS using Cloudflare on Pi-Hole ###
# Instructions originally found here: https://docs.pi-hole.net/guides/dns-over-https/
# Script put together by David Fuentes (https://github.com/dfuentes87/)

# download the precompiled binary and move it into place
echo "Downloading the binary and moving it into place.."
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz
tar -xvzf cloudflared-stable-linux-arm.tgz && rm ./cloudflared-stable-linux-arm.tgz
mv ./cloudflared /usr/local/bin/

echo "Creating the 'cloudflared' system user.."
useradd -s /usr/sbin/nologin -r -M cloudflared

# set file permissions
chmod +x /usr/local/bin/cloudflared
chown cloudflared:cloudflared /usr/local/bin/cloudflared

echo "Creating the systemd unit file.."
echo "
[Unit]
Description=cloudflared DNS over HTTPS proxyß
After=syslog.target network-online.target

[Service]
Type=simple
User=cloudflared
ExecStart=/usr/local/bin/cloudflared proxy-dns --port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query \
--upstream https://2606:4700:4700::1111/dns-query --upstream https://2606:4700:4700::1001/dns-query
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
" | tee /etc/systemd/system/cloudflared.service &>/dev/null #cant > with sudo

echo "Enabling cloudflared to run at startup and starting the service.."
systemctl enable cloudflared && systemctl start cloudflared

# check cloudflared is running and working
echo "cloudflared service status:"
systemctl status cloudflared | grep Active
echo -e "\nChecking if it's working (using dig).."
dig @127.0.0.1 -p 5053 google.com | grep -A1 ';; ANSWER\|;; SERVER:'

echo -e "\n\nDone."
echo -e "Don't forget to set your Upstream DNS Servers in Pi-Hole (use # instead of \
semicolons to signify ports):
\nFor IPv4 = 127.0.0.1#5053 \
\nFor IPv6 = ::1#5053"
