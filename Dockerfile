# CREATE docker network
# docker network create macbook
# DRY RUN
# docker container rm -f alpine; docker run -it --name alpine alpine;
# BUILD
# docker container rm -f atom; docker image rm -f atom; docker build -t atom:latest .;
# RUN
# docker run -dit --name atom -p 80:80 -v /Users/ccyhwong/Documents/TTI/playground/docker/public:/var/www/localhost/htdocs --net macbook atom;
# RUN INTO
# docker exec -it atom /bin/sh;

FROM alpine

# System update and install required software
RUN apk update
# RUN apk add bash curl
# RUN apk add openrc --no-cache
RUN apk add mysql-client

# To add user kelvin
# RUN addgroup -g 1234 www; adduser -h /home/kelvin -s /bin/ash -G www -u 1235 -D kelvin;

# To run as lighttpd, not root
# USER lighttpd

# Lighttpd
RUN apk add lighttpd

# PHP 7
# https://www.drupal.org/docs/system-requirements/php-requirements
RUN apk add php7 php7-fpm
RUN apk add php7-mysqli php7-pgsql php7-pdo php7-pdo_pgsql
RUN apk add php7-xml php7-xmlreader php7-xmlrpc php7-xmlwriter php7-simplexml
RUN apk add php7-gd
RUN apk add php7-openssl
RUN apk add php7-json
RUN apk add php7-curl
RUN apk add php7-mbstring

# Copy startup script
COPY ./startup.sh /root
RUN chmod +x /root/startup.sh

# Run startup script
ENTRYPOINT /root/startup.sh