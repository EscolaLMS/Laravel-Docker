FROM php:8.4-fpm-alpine
WORKDIR /var/www/html
EXPOSE 9000

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN apk add --no-cache \
    $PHPIZE_DEPS \  
    postgresql-dev \
    ffmpeg \
    unzip \
    libzip-dev libpng-dev  libxml2-dev openssl-dev\
    freetype-dev libpng-dev jpeg-dev libjpeg-turbo-dev \
    supervisor \ 
    bash \
    jpegoptim optipng pngquant gifsicle libwebp \
    nodejs npm 
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install zip pcntl bcmath gd session pcntl pdo pdo_pgsql pdo_mysql
RUN pecl install excimer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer

CMD ["/usr/bin/supervisord"]
ENTRYPOINT ["/docker-entrypoint.sh"]
