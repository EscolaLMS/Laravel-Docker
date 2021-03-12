FROM devilbox/php-fpm:7.4-base

RUN apt-get update && \
    apt-get install libonig-dev libzip-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev cron zip vim libcurl4-openssl-dev pkg-config libssl-dev libpng-dev libpq-dev postgresql -y \
    && docker-php-ext-install -j$(nproc) iconv soap mysqli mbstring\
    && docker-php-ext-install pdo_mysql xml fileinfo \
    && docker-php-ext-configure intl\
    && docker-php-ext-install intl\
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql\
    && docker-php-ext-install exif\
    && docker-php-ext-install bcmath\
    && docker-php-ext-install pcntl\
    && docker-php-ext-install zip\
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg\
    && docker-php-ext-install -j$(nproc) gd

# composer
RUN curl --silent --show-error https://getcomposer.org/composer.phar > composer.phar \
    && mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

# phpunit
RUN composer global require "phpunit/phpunit"
ENV PATH /root/.composer/vendor/bin:$PATH
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/bin/phpunit

# xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

#RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# node
RUN apt-get install -y gnupg2
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs
#RUN apt-get install -y npm

EXPOSE 9000
CMD ["php-fpm", "-F"]
