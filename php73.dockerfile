FROM registry.cn-shenzhen.aliyuncs.com/nyg/grpc_php_base:0.1 as grpc-base
FROM composer:1.8.6 as composer
FROM registry.cn-shenzhen.aliyuncs.com/nyg_base/phpunit:9.5.9 as phpunit
FROM php:7.3-cli

LABEL maintainer="nyg1991@aliyun.com"

#安装gd扩展
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) gd

#安装zip pdo_mysql扩展
RUN apt-get install -y zlib1g-dev && apt-get install -y libzip-dev && docker-php-ext-install -j$(nproc) zip && docker-php-ext-install -j$(nproc) pdo_mysql

#安装debug
RUN pecl install xdebug-2.8.1 && docker-php-ext-enable  xdebug

#安装grpc扩展
COPY --from=grpc-base \
  /usr/local/lib/php/extensions/no-debug-non-zts-20180731/grpc.so \
  /usr/local/lib/php/extensions/no-debug-non-zts-20180731/grpc.so

RUN docker-php-ext-enable grpc

COPY --from=grpc-base /github/grpc/cmake/build/third_party/protobuf/protoc \
  /usr/local/bin/protoc

COPY --from=grpc-base /github/grpc/cmake/build/grpc_php_plugin \
  /usr/local/bin/protoc-gen-grpc

#安装composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

#安装phpunit
COPY --from=phpunit /usr/local/bin/phpunit /usr/local/bin/phpunit

RUN chmod +x /usr/local/bin/composer && chmod +x /usr/local/bin/phpunit && echo 'test' > /etc/cluster
