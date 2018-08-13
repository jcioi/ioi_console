FROM ubuntu:18.04

ARG RUBY_VERSION=2.5
ARG RUBY_PACKAGE_VERSION=2.5.1-1ubuntu1
RUN apt-get update && \
  apt-get install -y \
  git-core \
  ruby=1:2.5.1 \
  ruby${RUBY_VERSION}=${RUBY_PACKAGE_VERSION} \
  libruby${RUBY_VERSION}=${RUBY_PACKAGE_VERSION} \
  ruby${RUBY_VERSION}-dev=${RUBY_PACKAGE_VERSION} \
  libxml2-dev libxslt-dev zlib1g-dev ruby-bundler

RUN mkdir -p /app /app/tmp

COPY . /app/

WORKDIR /app
RUN bundle install -j4 --deployment --without 'development test'
RUN bundle exec rails assets:precompile
RUN bundle exec rails webpacker:compile

CMD ["bundle", "exec", "puma", "-t", "2:16", "-w", "3", "-p", "8080"]
