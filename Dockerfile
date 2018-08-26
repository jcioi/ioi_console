FROM node:carbon-stretch AS webpack
RUN mkdir /app
WORKDIR /app
COPY package.json yarn.lock /app/
RUN yarn install && rm -rf /root/.cache/yarn
COPY config/webpack ./config/webpack
COPY config/webpacker.yml ./config/webpacker.yml
COPY .babelrc .postcssrc.yml ./
COPY app/javascript ./app/javascript
RUN NODE_ENV=production node_modules/.bin/webpack --config config/webpack/production.js

FROM ubuntu:18.04 AS gems
ARG RUBY_VERSION=2.5
ARG RUBY_PACKAGE_VERSION=2.5.1-1ubuntu1
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install -y \
  git-core \
  ruby=1:2.5.1 \
  ruby${RUBY_VERSION}=${RUBY_PACKAGE_VERSION} \
  libruby${RUBY_VERSION}=${RUBY_PACKAGE_VERSION} \
  ruby${RUBY_VERSION}-dev=${RUBY_PACKAGE_VERSION} \
  libxml2-dev libxslt-dev zlib1g-dev ruby-bundler \
  libpq-dev \
  tzdata

RUN mkdir -p /tmp /app
COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install -j300 --deployment --without 'development test' --path /gems
RUN cp -a /tmp/.bundle /app/.bundle

FROM ubuntu:18.04
ARG RUBY_VERSION=2.5
ARG RUBY_PACKAGE_VERSION=2.5.1-1ubuntu1
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install -y \
  git-core \
  ruby=1:2.5.1 \
  ruby${RUBY_VERSION}=${RUBY_PACKAGE_VERSION} \
  libruby${RUBY_VERSION}=${RUBY_PACKAGE_VERSION} \
  libxml2 libxslt1.1 zlib1g ruby-bundler \
  libpq5 \
  tzdata

WORKDIR /app

COPY --from=1 /app/.bundle /app/.bundle
COPY --from=1 /gems /gems

RUN mkdir -p /app /app/tmp
COPY . /app/
COPY --from=0 /app/public/packs ./public/packs

ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1

CMD ["bundle", "exec", "puma", "-t", "2:16", "-w", "3", "-p", "8080"]
