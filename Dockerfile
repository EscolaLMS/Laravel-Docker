# test 
# docker image build -t abc . && docker run -it abc bash
FROM devilbox/php-fpm:8.2-work

RUN apt-get update && apt-get install libonig-dev postgresql ffmpeg unzip gnupg2 gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libayatana-appindicator1 libnss3 lsb-release xdg-utils wget libgbm-dev libxshmfence-dev -y --no-install-recommends 

# image optimizers
RUN apt-get install jpegoptim optipng pngquant gifsicle webp -y 

# img svg optmizer & mjml 
RUN npm install -g svgo@1.3.2 mjml

# clearup 
RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
