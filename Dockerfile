ARG PHP_VERSION=8.2
ARG UID=1000
ARG GID=1001
ARG USERNAME=www-data

FROM php:${PHP_VERSION}-fpm

RUN apt-get update && apt-get install -yqq --no-install-recommends  libfcgi-bin libtool zip unzip libzip-dev git libpq-dev libicu-dev libpng-dev zlib1g-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo pdo_pgsql pgsql intl zip gd opcache  \
    && pecl install ast pcov redis xdebug apcu \
    && docker-php-ext-enable ast pcov redis apcu \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer
COPY docker/php/conf.d/symfony.ini $PHP_INI_DIR/conf.d/symfony.ini
ENV php_vars /usr/local/etc/php/conf.d/docker-vars.ini
RUN echo "max_execution_time=180" > ${php_vars} &&\
    echo "max_input_time=180" >> ${php_vars} && \
    echo "error_reporting = E_ALL & ~E_NOTICE & ~E_DEPRECATED" >> ${php_vars}