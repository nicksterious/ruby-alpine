FROM ruby:3.0-alpine3.13 as PassBuilder

ENV DEV_PACKAGES="tzdata shared-mime-info zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev postgresql-dev" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils libffi libffi-dev" \
    APACHE_PACKAGES="apache2-dev apr-util apr-util-dev apache2 apache2-proxy apache2-ctl"

RUN apk add $DEV_PACKAGES $DEV_PACKAGES2 $APACHE_PACKAGES && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    gem install -N nokogiri -- --use-system-libraries && \
    gem install passenger -v 6.0.9

RUN passenger-install-apache2-module




FROM ruby:3.0-alpine3.13 as RubyBuilder

ENV BASE_PACKAGES="tzdata shared-mime-info mariadb-connector-c" \
    MARIADB_PACKAGES="mysql-dev mariadb-connector-c-dev mariadb-dev musl-dev" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev postgresql-dev" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils libffi libffi-dev"

RUN apk update && apk add --update ca-certificates curl gnupg && \
    apk add $BASE_PACKAGES && \
    apk add $DEV_PACKAGES $DEV_PACKAGES2 && \
    apk add $MARIADB_PACKAGES && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    apk add nodejs npm && \
    gem install oj && \
    gem install RedCloth -v 4.3.2 && \
    gem install stackprof -v 0.2.17 && \
    gem install socketclusterclient -v 0.1.0 && \
    gem install sass-rails -v 5.1.0 && \
    gem install mysql2 -v 0.5.3




FROM ruby:3.0-alpine3.13

ENV BASE_PACKAGES="tzdata shared-mime-info" \
    APACHE_PACKAGES="apache2 apache2-proxy apache2-ctl"

RUN apk update && apk add --update ca-certificates curl gnupg && \
    apk add $BASE_PACKAGES && \
    apk add $APACHE_PACKAGES

COPY --from=PassBuilder /usr/local/bundle/ /usr/local/bundle/
COPY --from=RubyBuilder /usr/local/bundle/ /usr/local/bundle/

RUN touch /entrypoint.sh
WORKDIR /

#ENTRYPOINT ["passenger", "start", "--no-install-runtime", "--no-compile-runtime", "--no-download-binaries"]
CMD /entrypoint.sh
