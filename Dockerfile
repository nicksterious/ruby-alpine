# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.8
ARG ALPINE_VERSION=3.23
ARG BUNDLER_VERSION=4.0.7
ARG PASSENGER_VERSION=6.1.2

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS builder

ENV DEV_PACKAGES="tzdata shared-mime-info zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev mariadb-connector-c clang20-libclang" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils" \
    APACHE_PACKAGES="apache2-dev apr-util apr-util-dev apache2 apache2-proxy apache2-ctl apache2-ssl" \
    OTHER_PACKAGES="mc nmap wget curl git ncurses imagemagick-dev imagemagick vips vips-dev vips-tools npm nodejs bash jemalloc postgresql postgresql-dev mysql-client"

ENV BUNDLE_JOBS=8 \
    BUNDLE_RETRY=3 \
    LD_PRELOAD=/usr/lib/libjemalloc.so.2 \
    RUSTFLAGS="-C target-feature=-crt-static"

RUN apk add $DEV_PACKAGES $DEV_PACKAGES2 $APACHE_PACKAGES $OTHER_PACKAGES

RUN gem install bundler -v "${BUNDLER_VERSION}" --no-document \
    && gem install passenger -v "${PASSENGER_VERSION}" --no-document

RUN passenger-install-apache2-module

RUN apk add python3
RUN ln -sf python3 /usr/bin/python

RUN npm install -g yarn

ADD src/Gemfile* ./
RUN bundle install



