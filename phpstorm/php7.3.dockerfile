FROM composer:2.1.8 as composer
FROM registry.cn-shenzhen.aliyuncs.com/nyg_base/phpunit:9.5.9 as phpunit
FROM php:7.3-cli

#安装zip pdo_mysql扩展
RUN  apt-get update \
     && apt-get install -y zlib1g-dev \
     && apt-get install -y libzip-dev \
     && docker-php-ext-install -j$(nproc) zip \
     && docker-php-ext-install -j$(nproc) pdo_mysql

#安装debug
RUN pecl install xdebug-2.8.1 && docker-php-ext-enable  xdebug

#安装composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

#安装phpunit
COPY --from=phpunit /usr/local/bin/phpunit /usr/local/bin/phpunit

#设置为可执行
RUN chmod +x /usr/local/bin/composer && chmod +x /usr/local/bin/phpunit
