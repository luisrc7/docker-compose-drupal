FROM php:7.2-apache

# Set www-data user/group id to match Vagrant for when running under Vagrant
RUN groupmod -g 1000 www-data
RUN usermod -u 1000 -g 1000 www-data

# Install the PHP gd extension.
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd

# Install packages.
RUN apt-get update && apt-get install -y \
	git \
	zip \
	vim \
  wget \
  iputils-ping \
  mysql-client \
  unzip
RUN apt-get clean
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache

# Configure Apache.
COPY ./apache/000-default.conf /etc/apache2/sites-available/
RUN a2ensite 000-default
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www
RUN chmod 755 /var/www

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Configure composer bin path for composer packages inside the container and from exec.
RUN echo 'export PATH="/var/www/d8/vendor/bin:$PATH"' >> /root/.bashrc
ENV PATH /var/www/d8/vendor/bin:$PATH

# Setup PHP.
COPY ./php/php-docker.ini /usr/local/etc/php/conf.d/

# Setup XDebug.
# RUN pecl install xdebug-2.6.0alpha1
# COPY ./xdebug/xdebug-docker.ini /usr/local/etc/php/conf.d/
# RUN echo "zend_extension = '$(find / -name xdebug.so 2> /dev/null)'\n$(cat /usr/local/etc/php/conf.d/xdebug-docker.ini)" > /usr/local/etc/php/conf.d/xdebug-docker.ini

# Map directory ownership (docker-machine-nfs setup).
#RUN usermod -u 501 www-data
#RUN usermod -G dialout www-data
