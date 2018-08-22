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
  ruby${RUBY_VERSION}-dev=${RUBY_PACKAGE_VERSION} \
  libxml2-dev libxslt-dev zlib1g-dev ruby-bundler \
  libpq-dev \
  nodejs npm \
  tzdata

RUN update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10
RUN npm install -g yarn

RUN mkdir -p /app /app/tmp

COPY . /app/

WORKDIR /app
RUN bundle install -j4 --deployment --without 'development test'
RUN env GITHUB_CLIENT_ID=dummy GITHUB_CLIENT_SECRET=dummy bundle exec rails assets:precompile
RUN env GITHUB_CLIENT_ID=dummy GITHUB_CLIENT_SECRET=dummy bundle exec rails webpacker:compile

ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1

CMD ["bundle", "exec", "puma", "-t", "2:16", "-w", "3", "-p", "8080"]
