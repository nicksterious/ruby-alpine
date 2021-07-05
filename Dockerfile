
######################
# Stage: Passenger Builder
FROM ruby:3-alpine3.13 as PassBuilder

ENV DEV_PACKAGES="tzdata shared-mime-info zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev mariadb-connector-c" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils" \
    APACHE_PACKAGES="apache2-dev apr-util apr-util-dev apache2 apache2-proxy apache2-ctl"
    
RUN apk add $DEV_PACKAGES $DEV_PACKAGES2 $APACHE_PACKAGES && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    gem install passenger -v 6.0.9
    
RUN passenger-install-apache2-module
