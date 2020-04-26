#!/bin/bash

#Install dependencies
apt install -y php-curl php-gd php-zip

#Download grav and unzip it
wget -q -O grav-blog.zip -P /home/pi/ https://getgrav.org/download/core/grav-admin/latest &&
unzip /home/pi/grav-blog.zip -d /var/www/html/

#Move and rename the dir, then set proper permissions for it
mv /home/pi/grav-admin /var/www/html/notes &&
chown -R www-data:www-data /var/www/html/notes &&
chmod 755 /var/www/html/notes

#Add the needed Grav rules for lighttd
##we are going to add the lines to the very end of the file,
##so to make it easy let's delete the last closing bracket
sed '$d' /etc/lighttpd/external.conf
#now we can add the lines, including the closing bracket we removed
tee -a /etc/lighttpd/external.conf << 'EOF'
## GRAV RULES FOR LIGHTTPD ##
#PREVENTING EXPLOITS
$HTTP["querystring"] =~ "base64_encode[^(]*\([^)]*\)" {
    url.redirect = (".*" => "/notes/index.php"       )
}
$HTTP["querystring"] =~ "(<|%3C)([^s]*s)+cript.*(>|%3E)" {
    url.redirect = (".*" => "/notes/index.php" )
}
$HTTP["querystring"] =~ "GLOBALS(=|\[|\%[0-9A-Z])" {
    url.redirect = (".*" => "/notes/index.php" )
}
$HTTP["querystring"] =~ "_REQUEST(=|\[|\%[0-9A-Z])" {
    url.redirect = (".*" => "/notes/index.php" )
}

#REROUTING TO THE INDEX PAGE
url.rewrite-if-not-file = (
    "^/notes/(.*)$" => "/notes/index.php?$1"
)

#IMPROVING SECURITY
$HTTP["url"] =~ "^/notes/(LICENSE\.txt|composer\.json|composer\.lock|nginx\.conf|web\.config)$" {
    url.access-deny = ("")
}
$HTTP["url"] =~ "^/notes/(\.git|cache|bin|logs|backup|tests)/(.*)" {
    url.access-deny = ("")
}
$HTTP["url"] =~ "^/notes/(system|user|vendor)/(.*)\.(txt|md|html|yaml|yml|php|twig|sh|bat)$" {
    url.access-deny = ("")
}
$HTTP["url"] =~ "^/notes/(\.(.*))" {
    url.access-deny = ("")
}
url.access-deny = (".md","~",".inc")

#PREVENT BROWSING AND SET INDEXES
$HTTP["url"] =~ "^/notes($|/)" {
    dir-listing.activate = "disable"
    index-file.names = ( "index.php", "index.html" , "index.htm" )
}
}
EOF

#restart the web server
systemctl restart lighttpd.service

echo "Done."

