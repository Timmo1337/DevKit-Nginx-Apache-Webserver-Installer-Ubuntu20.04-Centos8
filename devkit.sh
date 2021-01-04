 #!/bin/sh
 usage()  
 {  
 echo "Usage: $0 ip/host"  
 exit 1  
 } 
if [ $# -ne 1 ] ; then
    usage
else
    ipinput=$1
    SYSTEM=$(lsb_release -sd)
	PORTAPACHE=$(shuf -i 1337-1555 -n 1)
	apache1='/etc/apache2/sites-available/000-default.conf'
	apache2='/etc/httpd/ports.conf'
	centosapache1='/etc/httpd/sites-available/000-default.conf'
	centosapache2='/etc/httpd/conf/httpd.conf'
	apacheindex='/var/www/html/index.php'
	htmldir='/var/www/html/'
	nginx1='/etc/nginx/nginx.conf'
	nginx2='/etc/nginx/sites-available/reverse.conf'
fi
COLUMNS=$(tput cols) 
title="DEVKIT WEBSERVER INSTALLATION" 
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "### DEVKIT WEBSERVER INSTALLATION - NGINX AS REVERSE PROXY FOR APACHE ###"
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "### INSTALLING ON '$ipinput' ###"
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "### INSTALLING NOW APACHE ON '$PORTAPACHE' ###"
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "### $SYSTEM ###"
if [[ $SYSTEM =~ .*ubuntu.* ]] 
then
echo 'UBUNTU INSTALLS'
apt-get --yes --force-yes install apache2
apt-get --yes --force-yes install php php-mysql libapache2-mod-php
apt-get --yes --force-yes install nginx
  else
  echo 'CENTOS INSTALLS'
yum -y install httpd
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf -y install yum-utils
dnf -y module reset php
dnf -y module install php:remi-8.0 -y
dnf -y install php -y
dnf -y install php-{cli,fpm,mysqlnd,zip,devel,gd,mbstring,curl,xml,pear,bcmath,json}
yum -y install nginx
firewall-cmd --zone=public --add-port=$PORTAPACHE/tcp --permanent
firewall-cmd --zone=public --add-port=$PORTAPACHE/udp --permanent
fi
#sed -i -e "s/\(Listen \).*/\1$PORTAPACHE/" /etc/apache2/ports.conf
if [[ $SYSTEM =~ .*ubuntu.* ]]
then 
touch $apache1
if [ -f $apache1 ]; then
   rm $apache1
printf "<VirtualHost *:$PORTAPACHE>

    ServerName $ipinput
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>" > $apache1
fi
touch $apache2
if [ -f $apache2 ]; then 
	rm $apache2 
	printf "# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen $PORTAPACHE

<IfModule ssl_module>
	Listen 443
</IfModule>

<IfModule mod_gnutls.c>
	Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" > $apache2
fi
else
touch $centosapache2
if [ -f $centosapache2 ]; then 
	rm $centosapache2 
printf '
ServerRoot "/etc/httpd"
Listen '$PORTAPACHE'

Include conf.modules.d/*.conf

User apache
Group apache

ServerAdmin root@localhost

<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>
<Directory "/var/www/html">
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"

LogLevel warn

    CustomLog "logs/access_log" combined
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types

    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz

    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>



EnableSendfile on

IncludeOptional conf.d/*.conf
' > $centosapache2
apachectl configtest
systemctl restart httpd
fi
fi
if [ -d $htmldir ]; then 
	rm -Rf $htmldir
	mkdir -p $htmldir
	fi
cd /var/www/html/
wget -c https://github.com/Timmo1337/DevKit-Nginx-Apache-Webserver-Installer-Ubuntu20.04-Centos8/blob/main/devkit-305x336.png?raw=true -O devkit-logo.png
printf "<center><img src='devkit-logo.png' alt='DevKit Webserver Installation Finished'><br/><h2>DevKit Webserver</h2><strong>Installation Complete</strong><br/>Frontend: Nginx on Port 80 | Backend: Apache on Port $PORTAPACHE<?php echo phpinfo(); ?>" > index.php
if [[ $SYSTEM =~ .*ubuntu.* ]]
then 
touch $nginx1
if [ -f $nginx1 ]; then
rm $nginx1 
printf "user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

   # Gzip Settings
        ##

        gzip on;
        gzip_disable \"msie6\";

        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_buffers 16 8k;
        gzip_http_version 1.1;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
		# Proxy Cache Settings
        proxy_cache_path /var/cache levels=1:2 keys_zone=reverse_cache:60m inactive=90m max_size=1000m;
	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
" > $nginx1
fi
touch $nginx2
if [ -f $nginx2 ]; then
rm $nginx2 
printf "server {
    listen 80;

    # Site Directory same in the apache virtualhost configuration
    root /var/www/html; 
    index index.php index.html index.htm;

    # Domain
    server_name $ipinput;

    location / {
        try_files \$uri \$uri/ /index.php;
    }


    # Reverse Proxy and Proxy Cache Configuration
    location ~ \.php$ {
 
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header Host \$host;
        proxy_pass http://127.0.0.1:$PORTAPACHE;

        # Cache configuration
        proxy_cache reverse_cache;
        proxy_cache_valid 3s;
        proxy_no_cache \$cookie_PHPSESSID;
        proxy_cache_bypass \$cookie_PHPSESSID;
        proxy_cache_key "\$scheme\$host\$request_uri";
        add_header X-Cache \$upstream_cache_status;
    }

    # Enable Cache the file 30 days
    location ~* .(jpg|png|gif|jpeg|css|mp3|wav|swf|mov|doc|pdf|xls|ppt|docx|pptx|xlsx)$ {
        proxy_cache_valid 200 120m;
        expires 30d;
        proxy_cache reverse_cache;
        access_log off;
    }

    # Disable Cache for the file type html, json
    location ~* .(?:manifest|appcache|html?|xml|json)$ {
        expires -1;
    }

    location ~ /\.ht {
        deny all;
    }
}" > $nginx2
fi
ln -s /etc/nginx/sites-available/reverse.conf /etc/nginx/sites-enabled/
else
touch $nginx1
if [ -f $nginx1 ]; then
rm $nginx1 
printf "user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {


	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

   # Gzip Settings
        ##

        gzip on;
        gzip_disable \"msie6\";

        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_buffers 16 8k;
        gzip_http_version 1.1;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
		# Proxy Cache Settings
        proxy_cache_path /var/cache levels=1:2 keys_zone=reverse_cache:60m inactive=90m max_size=1000m;
	##
	# Virtual Host Configs
	##
server {
    listen 80;

    # Site Directory same in the apache virtualhost configuration
    root /var/www/html; 
    index index.php index.html index.htm;

    # Domain
    server_name $ipinput;

    location / {
        try_files \$uri \$uri/ /index.php;
    }


    # Reverse Proxy and Proxy Cache Configuration
    location ~ \.php$ {
 
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header Host \$host;
        proxy_pass http://127.0.0.1:$PORTAPACHE;

        # Cache configuration
        proxy_cache reverse_cache;
        proxy_cache_valid 3s;
        proxy_no_cache \$cookie_PHPSESSID;
        proxy_cache_bypass \$cookie_PHPSESSID;
        proxy_cache_key "\$scheme\$host\$request_uri";
        add_header X-Cache \$upstream_cache_status;
    }

    # Enable Cache the file 30 days
    location ~* .(jpg|png|gif|jpeg|css|mp3|wav|swf|mov|doc|pdf|xls|ppt|docx|pptx|xlsx)$ {
        proxy_cache_valid 200 120m;
        expires 30d;
        proxy_cache reverse_cache;
        access_log off;
    }

    # Disable Cache for the file type html, json
    location ~* .(?:manifest|appcache|html?|xml|json)$ {
        expires -1;
    }

    location ~ /\.ht {
        deny all;
    }
}

}
" > $nginx1
fi
fi
nginx -t
systemctl restart nginx
curl -I $ipinput