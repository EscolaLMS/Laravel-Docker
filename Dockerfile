FROM devilbox/php-fpm:8.2-base

RUN apt-get update && apt-get install libonig-dev postgresql ffmpeg unzip -y 

# supervisord

RUN set -eux \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
    locales-all \
    postfix \
    postfix-pcre \
    cron \
    rsyslog \
    socat \
    supervisor \
    && rm -rf /var/lib/apt/lists/* \
    \
    # Fix: rsyslogd: imklog: cannot open kernel log (/proc/kmsg): Operation not permitted.
    && sed -i''  's/.*imklog.*//g' /etc/rsyslog.conf \
    \
    # Setup Supervisor
    && rm -rf /etc/supervisor* \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir -p /etc/supervisor/custom.d \
    && chown devilbox:devilbox /etc/supervisor/custom.d \
    \
    && (find /usr/local/bin  -type f -print0 | xargs -n1 -0 -P$(getconf _NPROCESSORS_ONLN) strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/lib  -type f -print0 | xargs -n1 -0 -P$(getconf _NPROCESSORS_ONLN) strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/sbin -type f -print0 | xargs -n1 -0 -P$(getconf _NPROCESSORS_ONLN) strip --strip-all -p 2>/dev/null || true)

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
