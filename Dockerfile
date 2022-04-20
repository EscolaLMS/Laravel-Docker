FROM devilbox/php-fpm:8.0-prod

RUN apt-get update && apt-get install libonig-dev postgresql ffmpeg -y 

# composer
RUN curl --silent --show-error https://getcomposer.org/composer.phar > composer.phar \
    && mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

# this is production image

# phpunit
# RUN composer global require "phpunit/phpunit"
# ENV PATH /root/.composer/vendor/bin:$PATH
# RUN ln -s /root/.composer/vendor/bin/phpunit /usr/bin/phpunit

# xdebug
# RUN pecl install xdebug && docker-php-ext-enable xdebug

# node & pupperteer

RUN apt-get update && apt-get install -y gnupg2 gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libayatana-appindicator1 libnss3 lsb-release xdg-utils wget libgbm-dev libxshmfence-dev

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential nodejs && npm install --global --unsafe-perm puppeteer && chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium

# image optimizers

RUN apt-get install jpegoptim optipng pngquant gifsicle webp -y \
    && npm install -g svgo@1.3.2

#mjml binary 
RUN npm install -g mjml

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
