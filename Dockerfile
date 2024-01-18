FROM devilbox/php-fpm:8.2-base

RUN set -eux \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
    alien \
    firebird-dev \
    freetds-dev \
    ghostscript \
    libaio-dev \
    libavif-dev \
    libbz2-dev \
    libc-client-dev \
    libcurl4-openssl-dev \
    libenchant-2-dev \
    libevent-dev \
    libfbclient2 \
    libfreetype6-dev \
    libgmp-dev \
    libib-util \
    libicu-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    liblz4-dev \
    liblzf-dev \
    libmagickwand-dev \
    libmariadb-dev \
    libmemcached-dev \
    libpcre3-dev \
    libpng-dev \
    libpq-dev \
    libpspell-dev \
    librabbitmq-dev \
    librdkafka-dev \
    libsasl2-dev \
    libsnmp-dev \
    libsodium-dev \
    libssl-dev \
    libtidy-dev \
    libvpx-dev \
    libwebp-dev \
    libxml2-dev \
    libxpm-dev \
    libxslt-dev \
    libyaml-dev \
    libzip-dev \
    libzstd-dev \
    snmp \
    unixodbc-dev \
    uuid-dev \
    zlib1g-dev \
    # Build tools
    autoconf \
    bison \
    bisonc++ \
    ca-certificates \
    curl \
    dpkg-dev \
    file \
    flex \
    g++ \
    gcc \
    git \
    lemon \
    libc-client-dev \
    libc-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    make \
    patch \
    pkg-config \
    re2c \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

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

# -------------------- Installing PHP Extension: gd --------------------
RUN set -eux \
    # Generic pre-command
    && ln -s /usr/lib/$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)/libXpm.* /usr/lib/ \
    # Installation: Version specific
    # Type:         Built-in extension
    # Custom:       configure command
    && docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype --with-avif \
    # Installation
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd \
    && true

# -------------------- Installing PHP Extension: opcache --------------------
RUN set -eux \
    # Version specific pre-command
    && curl -sS https://raw.githubusercontent.com/php/php-src/php-8.0.6/ext/opcache/Optimizer/zend_dfg.h > /usr/local/include/php/Zend/Optimizer/zend_dfg.h \
    # Installation: Version specific
    # Type:         Built-in extension
    # Installation
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) opcache \
    && true

# -------------------- Installing PHP Extension: redis --------------------
RUN set -eux \
    # Generic pre-command
    && if [ -f /usr/include/liblzf/lzf.h ]; then \
    ln -s /usr/include/liblzf/lzf.h /usr/include/; \
    fi \
    \
    # Installation: Generic
    # Type:         GIT extension
    && git clone https://github.com/phpredis/phpredis /tmp/redis \
    && cd /tmp/redis \
    # Custom:       Branch
    && git checkout $(git tag | grep -E '^[.0-9]+$' | sort -V | tail -1) \
    # Custom:       Install command
    && REDIS_ARGS=""; \
    if php -m | grep -q "igbinary"; then \
    REDIS_ARGS="${REDIS_ARGS} --enable-redis-igbinary"; \
    fi; \
    if php -m | grep -q "lz4"; then \
    REDIS_ARGS="${REDIS_ARGS} --enable-redis-lz4 --with-liblz4=/usr"; \
    fi; \
    if php -m | grep -q "lzf"; then \
    REDIS_ARGS="${REDIS_ARGS} --enable-redis-lzf --with-liblzf=/usr"; \
    fi; \
    if php -m | grep -q "msgpack"; then \
    REDIS_ARGS="${REDIS_ARGS} --enable-redis-msgpack"; \
    fi; \
    if php -m | grep -q "zstd"; then \
    REDIS_ARGS="${REDIS_ARGS} --enable-redis-zstd"; \
    fi; \
    phpize \
    && ./configure --enable-redis ${REDIS_ARGS} \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    \
    # Enabling
    && docker-php-ext-enable redis \
    && true

# -------------------- Installing PHP Extension: pdo_pgsql --------------------
RUN set -eux \
    # Installation: Generic
    # Type:         Built-in extension
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) pdo_pgsql \
    && true

# -------------------- Installing PHP Extension: pgsql --------------------
RUN set -eux \
    # Installation: Generic
    # Type:         Built-in extension
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) pgsql \
    && true

# -------------------- Installing PHP Extension: sodium --------------------
RUN set -eux \
    # Installation: Generic
    # Type:         Built-in extension
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) sodium \
    && true


# -------------------- Installing PHP Extension: zip --------------------
RUN set -eux \
    # Installation: Generic
    # Type:         Built-in extension
    # Custom:       configure command
    && docker-php-ext-configure zip --with-zip \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) zip \
    && true

# -------------------- Installing PHP Extension: pcntl --------------------
RUN set -eux \
    # Installation: Generic
    # Type:         Built-in extension
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) pcntl \
    && true

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
