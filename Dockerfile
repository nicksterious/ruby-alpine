
######################
# Stage: Passenger Builder
FROM ruby:3.0.2-alpine3.14 as PassBuilder

RUN gem install bundler -v 2.2.32

ENV DEV_PACKAGES="tzdata shared-mime-info zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev mariadb-connector-c" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils" \
    APACHE_PACKAGES="apache2-dev apr-util apr-util-dev apache2 apache2-proxy apache2-ctl"

RUN apk add $DEV_PACKAGES $DEV_PACKAGES2 $APACHE_PACKAGES && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    gem install passenger -v 6.0.9
    
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
    php7-apache2 php7-gd php7-mysqli php7-zlib php7-curl php7-mbstring php7-pdo php7-pdo_mysql php7-xml php7-xmlreader php7-xmlwriter \
    php7-ctype php7-json php7-tokenizer php7-bcmath php7-openssl php7-zip php7-session

RUN ln -sf python3 /usr/bin/python

RUN npm install -g yarn


ADD src/Gemfile* ./
RUN bundle install --jobs=8


