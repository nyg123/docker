FROM php:7.3-stretch

RUN apt-get -qq update && apt-get -qq install -y \
  autoconf automake cmake curl git libtool \
  pkg-config unzip zlib1g-dev

ARG MAKEFLAGS=-j8


WORKDIR /github/grpc

RUN git clone -b v1.34.0 https://github.com/grpc/grpc . && \
  git submodule update --init --recursive

WORKDIR /github/grpc/cmake/build

RUN cmake ../.. && \
  make protoc grpc_php_plugin

RUN pecl install grpc
