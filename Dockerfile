
######################
# Stage: Passenger Builder
FROM ruby:3-alpine3.13 as PassBuilder

ENV DEV_PACKAGES="tzdata shared-mime-info zlib-dev libxml2-dev libxslt-dev yaml-dev sqlite-dev" \
    DEV_PACKAGES2="procps pcre libstdc++ glib-dev libc-dev openssl-dev make libxml2-dev build-base linux-headers curl-dev pcre-dev coreutils libffi libffi-dev" \
    APACHE_PACKAGES="apache2-dev apr-util apr-util-dev apache2 apache2-proxy apache2-ctl"
    
RUN apk add $DEV_PACKAGES $DEV_PACKAGES2 $APACHE_PACKAGES && \
    apk add --update-cache --repository 'http://nl.alpinelinux.org/alpine/edge/testing' libexecinfo libexecinfo-dev && \
    gem install passenger -v 6.0.9
    
RUN passenger-install-apache2-module

######################
# Stage: Builder
FROM ruby:3-alpine3.13 as Builder

ARG FOLDERS_TO_REMOVE
ARG RAILS_ENV
ENV RAILS_ENV ${RAILS_ENV}
ENV HOME=/home/rails
ENV LANG=C.UTF-8
ENV RAILS_ROOT=$HOME/app
ENV SECRET_KEY_BASE=foo
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

RUN apk add --update --no-cache \
    build-base \
    postgresql-dev \
    git \
    imagemagick \
    nodejs \
    yarn \
    tzdata \
    shared-mime-info \
    mysql-client \
    mariadb-dev \
    chromium \
    chromium-chromedriver \
    curl
    
RUN mkdir $HOME

WORKDIR $RAILS_ROOT

# copy compiled passenger
COPY --from=PassBuilder /usr/local/bundle/gems/passenger-6.0.9 /usr/local/bundle/gems/

RUN echo "================================" && ls /usr/local/bundle/gems && echo "================================"

# Install gems

ADD src/Gemfile* $RAILS_ROOT/

RUN gem install bundler  && bundle install -j "$(getconf _NPROCESSORS_ONLN)" --retry 3

RUN echo "================================" && cat Gemfile.lock && echo "================================"
 
 # Remove unneeded files (cached *.gem, *.o, *.c)
RUN rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

# Add the Rails app
ADD . $RAILS_ROOT

# Precompile assets
#RUN rake webpacker:compile RAILS_ENV=production NODE_ENV=production
#RUN yarn cache clean

# Remove folders not needed in resulting image
RUN rm -rf $FOLDERS_TO_REMOVE

################################ Stage Final
FROM ruby:3-alpine3.13

ARG ADDITIONAL_PACKAGES

# Add Alpine packages
RUN apk add --update --no-cache \
    mysql-client \
    mariadb-dev \
    imagemagick \
    tzdata \
    shared-mime-info \
    bash \
    curl \
    nodejs \
    mariadb-connector-c \
    apache2 apache2-proxy apache2-ctl \
    nodejs npm \
    $ADDITIONAL_PACKAGES
    
ENV RAILS_ENV ${RAILS_ENV}
ENV HOME=/home/rails
ENV LANG=C.UTF-8
ENV RAILS_ROOT=$HOME/app
ENV SECRET_KEY_BASE=foo
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

WORKDIR $RAILS_ROOT

# Copy app with gems from former build stage
COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder $RAILS_ROOT $RAILS_ROOT

RUN mkdir -p ./lib/mariadb && ln -s /usr/lib/mariadb/plugin $RAILS_ROOT/lib/mariadb/plugin \
  && mkdir -p /usr/usr/lib/mariadb/plugin/ \
  && ln -s /usr/lib/mariadb/plugin/caching_sha2_password.so /usr/usr/lib/mariadb/plugin/caching_sha2_password.so
  
RUN mkdir -p ./tmp/pids 

RUN echo "alias rails='bundle exec rails'" > $HOME/.bashrc
