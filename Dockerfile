FROM ruby:3.0-alpine3.13

ENV UTILS="mc nmap wget curl" \
    BASE_PACKAGES="tzdata  shared-mime-info mariadb-connector-c" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev postgresql-dev" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils libffi libffi-dev" \
    APACHE_PACKAGES="apache2-dev apr-util apr-util-dev apache2 apache2-proxy apache2-ctl" \
    RUBY_PACKAGES="ruby-dev ruby-io-console" \
    MARIADB_PACKAGES="mysql-dev mariadb-connector-c-dev mariadb-dev musl-dev"

ENV BUILD=0.0.1

RUN apk update && apk add --update ca-certificates curl gnupg && \
    apk add $UTILS $BASE_PACKAGES && \
    apk add $DEV_PACKAGES $DEV_PACKAGES2 && \
    apk add $APACHE_PACKAGES $MARIADB_PACKAGES && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    apk add nodejs npm && \
    gem install oj && \
    gem install -N nokogiri -- --use-system-libraries && \
    gem install passenger -v 6.0.9 && \
    gem install RedCloth -v 4.3.2 && \
    gem install socketclusterclient -v 0.1.0 && \
    gem install sass-rails -v 5.1.0 && \
    gem install mysql2 -v 0.5.3

RUN passenger-install-apache2-module

RUN touch /entrypoint.sh
WORKDIR /

#ENTRYPOINT ["passenger", "start", "--no-install-runtime", "--no-compile-runtime", "--no-download-binaries"]
CMD /entrypoint.sh
