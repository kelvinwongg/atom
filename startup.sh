# https://wiki.alpinelinux.org/wiki/Production_LAMP_system:_Lighttpd_%2B_PHP_%2B_MySQL
# Important: Openrc is not available in docker container,
# alternative method to kick start service is needed.


# 
# Lighttpd
# 
mkdir -p /var/www/localhost/htdocs/stats /var/log/lighttpd /var/lib/lighttpd
sed -i -r 's#\#.*server.port.*=.*#server.port          = 80#g' /etc/lighttpd/lighttpd.conf
sed -i -r 's#\#.*server.event-handler = "linux-sysepoll".*#server.event-handler = "linux-sysepoll"#g' /etc/lighttpd/lighttpd.conf
chown -R lighttpd:lighttpd /var/www/localhost/
chown -R lighttpd:lighttpd /var/lib/lighttpd
chown -R lighttpd:lighttpd /var/log/lighttpd
# rc-update add lighttpd default
# rc-service lighttpd restart
echo "it works" > /var/www/localhost/htdocs/index.html
sed -i -r 's#\#.*mod_status.*,.*#    "mod_status",#g' /etc/lighttpd/lighttpd.conf
sed -i -r 's#.*status.status-url.*=.*#status.status-url  = "/stats/server-status"#g' /etc/lighttpd/lighttpd.conf
sed -i -r 's#.*status.config-url.*=.*#status.config-url  = "/stats/server-config"#g' /etc/lighttpd/lighttpd.conf
# rc-service lighttpd restart


# 
# PHP Global Configuration
# 
sed -i -r 's|.*cgi.fix_pathinfo=.*|cgi.fix_pathinfo=1|g' /etc/php*/php.ini
sed -i -r 's#.*safe_mode =.*#safe_mode = Off#g' /etc/php*/php.ini
sed -i -r 's#.*expose_php =.*#expose_php = Off#g' /etc/php*/php.ini
sed -i -r 's#memory_limit =.*#memory_limit = 536M#g' /etc/php*/php.ini
sed -i -r 's#upload_max_filesize =.*#upload_max_filesize = 128M#g' /etc/php*/php.ini
sed -i -r 's#post_max_size =.*#post_max_size = 256M#g' /etc/php*/php.ini
sed -i -r 's#^file_uploads =.*#file_uploads = On#g' /etc/php*/php.ini
sed -i -r 's#^max_file_uploads =.*#max_file_uploads = 12#g' /etc/php*/php.ini
sed -i -r 's#^allow_url_fopen = .*#allow_url_fopen = On#g' /etc/php*/php.ini
sed -i -r 's#^.default_charset =.*#default_charset = "UTF-8"#g' /etc/php*/php.ini
sed -i -r 's#^.max_execution_time =.*#max_execution_time = 150#g' /etc/php*/php.ini
sed -i -r 's#^max_input_time =.*#max_input_time = 90#g' /etc/php*/php.ini


# 
# PHP-FPM Configuration
# 
mkdir -p /var/run/php-fpm7/
chown lighttpd:root /var/run/php-fpm7
sed -i -r 's|^.*listen =.*|listen = /run/php-fpm7/php7-fpm.sock|g' /etc/php*/php-fpm.d/www.conf
sed -i -r 's|^pid =.*|pid = /run/php-fpm7/php7-fpm.pid|g' /etc/php*/php-fpm.conf
sed -i -r 's|^.*listen.mode =.*|listen.mode = 0640|g' /etc/php*/php-fpm.d/www.conf
rc-update add php-fpm7 default
service php-fpm7 restart


# 
# Lighttpd + PHP-FPM Configuration
# 
mkdir -p /var/www/localhost/cgi-bin
sed -i -r 's#\#.*mod_alias.*,.*#    "mod_alias",#g' /etc/lighttpd/lighttpd.conf
sed -i -r 's#.*include "mod_cgi.conf".*#   include "mod_cgi.conf"#g' /etc/lighttpd/lighttpd.conf
sed -i -r 's#.*include "mod_fastcgi.conf".*#\#   include "mod_fastcgi.conf"#g' /etc/lighttpd/lighttpd.conf
sed -i -r 's#.*include "mod_fastcgi_fpm.conf".*#   include "mod_fastcgi_fpm.conf"#g' /etc/lighttpd/lighttpd.conf
cat > /etc/lighttpd/mod_fastcgi_fpm.conf << EOF
server.modules += ( "mod_fastcgi" )
index-file.names += ( "index.php" )
fastcgi.server = (
    ".php" => (
      "localhost" => (
        "socket"                => "/var/run/php-fpm7/php7-fpm.sock",
        "broken-scriptfilename" => "enable"
      ))
)
EOF
sed -i -r 's|^.*listen =.*|listen = /var/run/php-fpm7/php7-fpm.sock|g' /etc/php*/php-fpm.d/www.conf
sed -i -r 's|^.*listen.owner = .*|listen.owner = lighttpd|g' /etc/php*/php-fpm.d/www.conf
sed -i -r 's|^.*listen.group = .*|listen.group = lighttpd|g' /etc/php*/php-fpm.d/www.conf
sed -i -r 's|^.*listen.mode = .*|listen.mode = 0660|g' /etc/php*/php-fpm.d/www.conf
# rc-service php-fpm7 restart
# rc-service lighttpd restart
echo "<?php echo phpinfo(); ?>" > /var/www/localhost/htdocs/info.php

# 
# Start PHP-FPM
# 
/usr/sbin/php-fpm7

# 
# Start lighttpd in the foregroud
#
lighttpd -D -f /etc/lighttpd/lighttpd.conf