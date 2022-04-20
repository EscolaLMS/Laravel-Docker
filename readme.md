Escolas Laravel Docker

Example usage

```yaml
version: "3.5"
networks:
  escola_lms:
    name: escola_lms
    driver: bridge
services:
  nginx:
    image: nginx:latest
    ports:
      - "1000:80"
    volumes:
      - ./:/var/www/html
      - ./docker/conf/nginx:/etc/nginx/conf.d/
      - ./docker/www_logs/nginx:/var/log/nginx
    links:
      - escola_lms_app
    networks:
      - escola_lms
  escola_lms_app:
    image: escolalms/php:8-prod ## or escolalms/php:8-work for debugginh
    volumes:
      - ./:/var/www/html
      - ./docker/conf/php/php-custom.ini:/usr/local/etc/php/conf.d/php-custom.ini
      - ./docker/conf/php/xxx-devilbox-default-php.ini:/usr/local/etc/php/conf.d/xxx-devilbox-default-php.ini
      - ./docker/conf/supervisor/horizon.conf:/etc/supervisor/custom.d/horizon.conf
    networks:
      - escola_lms

  mysql:
    networks:
      - escola_lms
    ports:
      - "3306:3306"
    image: mariadb:10.5
    volumes:
      - ./docker/mysql-data:/var/lib/mysql
      - ./docker/conf/mysql/mysql:/etc/mysql/conf.d
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: database
      MYSQL_PASSWORD: password
      MYSQL_USER: username

  postgres:
    image: postgres:12
    ports:
      - "5432:5432"
    networks:
      - escola_lms
    volumes:
      - ./docker/postgres-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=default
      - POSTGRES_USER=default
      - POSTGRES_PASSWORD=secret
      - TZ=Europe/Warsaw

  adminer:
    networks:
      - escola_lms
    image: adminer
    ports:
      - 8078:8080

  pgadmin:
    networks:
      - escola_lms
    image: dpage/pgadmin4
    volumes:
      - ./docker/pgadmin:/var/lib/pgadmin

    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: root
    ports:
      - "5050:80"

  mailhog:
    networks:
      - escola_lms
    image: mailhog/mailhog
    logging:
      driver: "none" # disable saving logs
    ports:
      - 1025:1025 # smtp server
      - 8025:8025 # web ui

  redis:
    networks:
      - escola_lms
    image: "redis"
    command: redis-server --requirepass escola_lms
    ports:
      - "6379:6379"
```
