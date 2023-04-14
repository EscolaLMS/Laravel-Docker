FROM devilbox/php-fpm:8.1-prod

RUN apt-get update && apt-get install libonig-dev postgresql ffmpeg unzip -y 

# composer
RUN curl --silent --show-error https://getcomposer.org/composer.phar > composer.phar \
    && mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential nodejs 

# image optimizers
RUN apt-get install jpegoptim optipng pngquant gifsicle webp -y \
    && npm install -g svgo@1.3.2

# mjml binary 
RUN npm install -g mjml

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
