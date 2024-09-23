FROM devilbox/php-fpm:8.2-prod

RUN apt-get update && apt-get install libonig-dev postgresql ffmpeg unzip -y 

# composer
RUN curl --silent --show-error https://getcomposer.org/composer.phar > composer.phar \
    && mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

# image optimizers
RUN apt-get install jpegoptim optipng pngquant gifsicle webp -y 

RUN apt-get clean && apt-get -y autoremove

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
ENTRYPOINT ["/docker-entrypoint.sh"]