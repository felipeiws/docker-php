FROM php:7.3.4-apache

RUN apt-get update \
&& apt-get install -yf vim curl sqlite3

# Instalando o Composer
RUN php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN apt-get install -yf \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libpng-dev libxpm-dev \
    libfreetype6-dev

#install some base extensions
# Install php extentions
RUN apt-get update && apt-get install -yf libxml2-dev && docker-php-ext-install soap mbstring pdo pdo_mysql mysqli
RUN apt-get update && apt-get install -yf libpq-dev && docker-php-ext-install pdo pdo_pgsql

RUN apt-get install -yf \
        libzip-dev \
        zip \
  && docker-php-ext-configure zip --with-libzip \
  && docker-php-ext-install zip

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Configura também as pastas para o novo usuário
RUN chown -R 1000:1000 /var/www/html
RUN chown -R 1000:1000 /root/.composer

# The base image does not have php.ini. 
# Copy our own, with xdebug settings
ADD ./php.ini /usr/local/etc/php/

# Turn mod_rewrite on
RUN /usr/sbin/a2enmod rewrite
RUN a2enmod rewrite

EXPOSE 80
