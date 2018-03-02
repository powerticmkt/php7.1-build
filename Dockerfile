FROM php:7.1-apache

RUN apt-get update && apt-get install --no-install-recommends -y \
    cron \
    sudo \
    libc-client-dev \
    build-essential  \
    oftware-properties-common \
    libicu-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libssl-dev \
    unzip \
    zip \
    htop \
    tcl8.5 \
    nano \
    dialog \
    g++ \
    git \
    libmagickwand-dev \
    imagemagick \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    wget \
    groff \
    cron \
    libmemcached-dev \
    zlib1g-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    mysql-client

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos;

RUN docker-php-ext-install bcmath imap exif intl mbstring mcrypt mysqli pdo xml pdo_mysql zip gd soap

RUN docker-php-ext-configure bcmath

# Install the PHP gd library
RUN docker-php-ext-configure gd \
          --enable-gd-native-ttf \
          --with-jpeg-dir=/usr/lib \
          --with-freetype-dir=/usr/include/freetype2 && \
        docker-php-ext-install gd

RUN pecl install imagick -y

RUN docker-php-ext-enable imagick

# Set  PHP.ini settings
RUN { \
      echo 'opcache.memory_consumption=256M'; \
      echo 'opcache.interned_strings_buffer=8'; \
      echo 'opcache.max_accelerated_files=8000'; \
      echo 'opcache.revalidate_freq=2'; \
      echo 'opcache.fast_shutdown=1'; \
      echo 'opcache.enable_cli=1'; \
      echo 'memory_limit=512M'; \
      echo 'file_uploads = On'; \
      echo 'upload_max_filesize=128M'; \
      echo 'post_max_size=128M'; \
      echo 'max_execution_time=999999'; \
    } > /usr/local/etc/php/conf.d/powertic.ini

RUN a2enconf powertic


# Set Apache Cache Settings
RUN { \
      echo  '<filesMatch ".(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf)$">'; \
      echo  '  Header set Cache-Control "max-age=8400600, public"'; \
      echo  '</filesMatch>'; \
      echo  '<IfModule mod_expires.c>'; \
      echo  '  ExpiresActive On'; \
      echo  '  ExpiresByType image/jpg "access 1 year"'; \
      echo  '  ExpiresByType image/jpeg "access 1 year"'; \
      echo  '  ExpiresByType image/gif "access 1 year"'; \
      echo  '  ExpiresByType image/png "access 1 year"'; \
      echo  '  ExpiresByType text/css "access 1 month"'; \
      echo  '  ExpiresByType application/pdf "access 1 month"'; \
      echo  '  ExpiresByType application/javascript "access 1 month"'; \
      echo  '  ExpiresByType application/x-javascript "access 1 month"'; \
      echo  '  ExpiresByType application/x-shockwave-flash "access 1 month"'; \
      echo  '  ExpiresByType image/x-icon "access 1 year"'; \
      echo  '  ExpiresDefault "access 1 month"'; \
      echo  '</IfModule>'; \
    } > /etc/apache2/conf-available/powertic.conf



# Enable Apache Modules
RUN a2enmod rewrite
RUN a2enmod expires
