
######################
# Stage: Passenger Builder
FROM ruby:3.4.8-alpine3.23 as PassBuilder

RUN gem install bundler -v 2.6.9

ENV DEV_PACKAGES="tzdata shared-mime-info zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev mariadb-connector-c" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils" \
    APACHE_PACKAGES="apache2-dev apr-util apr-util-dev apache2 apache2-proxy apache2-ctl"

RUN apk add $DEV_PACKAGES $DEV_PACKAGES2 $APACHE_PACKAGES && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    gem install passenger -v 6.1.2
    
RUN passenger-install-apache2-module

RUN apk add mc nmap wget curl git \
    imagemagick-dev \
    imagemagick \
    vips vips-dev vips-tools \
    npm nodejs \
    mariadb-connector-c \
    bash \
    postgresql-dev \
    python3 python2 \
    postgresql mysql-client \
    php83-apache2 php83-gd php83-mysqli php83-zlib php83-curl php83-mbstring php83-pdo php83-pdo_mysql php83-xml php83-xmlreader php83-xmlwriter \
    php83-ctype php83-json php83-tokenizer php83-bcmath php83-openssl php83-zip php83-session

RUN ln -sf python3 /usr/bin/python

RUN npm install -g yarn


ADD src/Gemfile* ./
RUN bundle install --jobs=8


