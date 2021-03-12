Escolas Laravel Docker

Example usage

```yaml
version: "3.5"
networks:
  app:
    name: app
    driver: bridge
services:
  nginx:
    image: nginx:latest
    ports:
      - "1000:80"
    volumes:
      - ./:/var/www/html
      - ./docker/conf/:/etc/nginx/conf.d/
      - ./docker/www_logs/nginx:/var/log/nginx
    links:
      - php
    networks:
      - app
  php:
    build: docker/containers/php-fpm
    command: bash -c "/etc/init.d/cron start && php-fpm -F"
    volumes:
      - ./:/var/www/html:cached
      - ./docker/php-custom.ini:/usr/local/etc/php/conf.d/php-custom.ini
    networks:
      - app
  mysql:
    networks:
      - app
    image: mariadb:10.5
    volumes:
      - ./docker/mysql-data:/var/lib/mysql
      - ./docker/conf/mysql:/etc/mysql/conf.d
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: database
  phpmyadmin:
    networks:
      - app
    image: phpmyadmin/phpmyadmin
    depends_on:
      - mysql
    ports:
      - "8079:80"
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USERNAME: root
      PMA_HOST: mysql
  postgres:
    image: postgres:12
    networks:
      - app
    volumes:
      - ./docker/postgres-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=default
      - POSTGRES_USER=default
      - POSTGRES_PASSWORD=secret
      - TZ=Europe/Warsaw
```
