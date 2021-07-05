FROM ruby:3.0-alpine3.13

ENV PATH="/passenger/bin:$PATH" \
    UTILS="mc nmap wget curl" \
    BASE_PACKAGES="tzdata ruby-io-console" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev postgresql-dev mysql-dev apache2-dev apr-util apr-util-dev" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev ruby-dev coreutils libffi libffi-dev"

ENV BUILD=0.0.1

RUN apk update && apk add --update ca-certificates curl gnupg && \

    # install build deps
    # apk add ruby procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev ruby-rake build-base linux-headers curl-dev pcre-dev ruby-dev coreutils ruby-io-console libffi libffi-dev ruby-bundler && \
    apk add $UTILS $BASE_PACKAGES $DEV_PACKAGES $DEV_PACKAGES2 && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    apk add shared-mime-info && \


    # Install ffi while we have an build development available. Version is from the Gemfile.lock in the actual project, adjust to your needs!
    #gem install ffi -v 1.9.10 && \
    # The same goes for eventmachine
    #gem install eventmachine -v 1.0.9.1 && \
    # ...and json. And any other gem that requires native compilation.
    # gem install json -v 1.8.3 && \
    gem install oj && \
    gem install -N nokogiri -- --use-system-libraries && \
    gem install passenger -v 6.0.9 && \
    gem install RedCloth -v 4.3.2 && \
    apk add apache2 apache2-proxy apache2-ctl

RUN passenger-install-apache2-module

    # cleanup
RUN apk del $DEV_PACKAGES $DEV_PACKAGES2

RUN touch /entrypoint.sh
WORKDIR /

#ENTRYPOINT ["passenger", "start", "--no-install-runtime", "--no-compile-runtime", "--no-download-binaries"]
CMD /entrypoint.sh
