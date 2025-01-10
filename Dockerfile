FROM php:8.3-fpm-bookworm
WORKDIR /var/www/html
EXPOSE 9000

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    $PHPIZE_DEPS \  
    libpq-dev \
    ffmpeg \
    unzip \
    libzip-dev libpng-dev  libxml2-dev openssl libssl-dev \
    libfreetype6-dev libpng-dev libjpeg-dev libjpeg-dev libavif-dev libpng-dev libxpm-dev libvpx-dev libwebp-dev \
    supervisor \ 
    jpegoptim optipng pngquant gifsicle webp \
    nodejs npm \ 
    && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype --with-avif \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install zip pcntl bcmath gd session pcntl pdo pdo_pgsql pdo_mysql intl opcache
RUN pecl install apcu
RUN docker-php-ext-enable apcu
#RUN pecl install excimer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer

CMD ["/usr/bin/supervisord"]
ENTRYPOINT ["/docker-entrypoint.sh"]
