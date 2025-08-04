FROM php:8.3-fpm-alpine

WORKDIR /var/www/html
EXPOSE 9000

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

RUN apk add --no-cache \
    $PHPIZE_DEPS \
    postgresql-dev \
    ffmpeg \
    unzip \
    libzip-dev \
    libxml2-dev \
    openssl-dev \
    libpng-dev \
    freetype-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
    libavif-dev \
    libxpm-dev \
    libvpx-dev \
    libwebp-dev \
    supervisor \
    bash \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    libwebp

RUN docker-php-ext-configure gd \
        --enable-gd \
        --with-webp \
        --with-jpeg \
        --with-xpm \
        --with-freetype \
        --with-avif \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure pgsql --with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install \
        zip \
        bcmath \
        gd \
        session \
        pdo \
        pdo_pgsql \
        pdo_mysql \
        intl \
        opcache \
    && pecl install apcu redis \
    && docker-php-ext-enable apcu redis

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

CMD ["/usr/bin/supervisord"]
ENTRYPOINT ["/docker-entrypoint.sh"]
