FROM debian:buster

# Update local package index & install necessary packages
RUN apt update && apt install -y \
	nginx \
	mariadb-server \
	sendmail \
	wget \
	php7.3 php-fpm php-zip php-mysql php-mbstring php-cli php-curl php-gd php-intl php-soap php-xml php-xmlrpc 

# RUN apt upgrade -y (not necessary as packages cannot be upgraded within unprivileged container)

# Copying source files
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost
COPY ./srcs/wordpress.tar.gz /var/www/html/
COPY ./srcs/sqlsetup.sql /var/
COPY ./srcs/wpsetup.sql /var/

# Generating SSL key & certificate
RUN openssl genrsa -out /etc/ssl/certs/localhost.key 2048 && \
	openssl req -x509 -days 356 -nodes -new -key /etc/ssl/certs/localhost.key \
	-subj '/C=NL/ST=NH/L=Amsterdam/O=Codam/CN=localhost' -out /etc/ssl/certs/localhost.crt

# Activate config by linking from nginx dir
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost && nginx -t

# Install & configure phpMyAdmin
WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar xf phpMyAdmin-5.0.1-english.tar.gz && rm phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin

# Install Wordpress & secure file permissions
RUN tar xf ./wordpress.tar.gz && rm -rf wordpress.tar.gz
RUN chmod -R 755 wordpress

# Import MySQL & Wordpress setup from SQL dump
RUN service mysql start && mysql -u root mysql < /var/sqlsetup.sql \
	&& mysql -u root mysql < /var/www/html/phpmyadmin/sql/create_tables.sql \
	&& mysql -u root wordpress < /var/wpsetup.sql

# Increasing file size limit
RUN cd /etc/php/7.3/fpm && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 20M/g' php.ini

# Changing ownership of web root & dir/files within
RUN chown -R www-data:www-data /var/www
RUN chmod 755 -R /var/www

# Start services
CMD service php7.3-fpm start && \
	service nginx start && \
	service mysql start && \
	service sendmail start && \
	bash

# Exposing ports for HTTP & HTTPS
EXPOSE 80 443
