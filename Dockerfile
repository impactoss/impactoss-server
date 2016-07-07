FROM ruby:2.3.1-slim
ENV PHANTOM_JS_VERSION 2.1.1
ENV PHANTOM_JS_PACKAGE phantomjs-$PHANTOM_JS_VERSION-linux-x86_64
EXPOSE 3000

RUN apt-get update -qq &&\
    apt-get install -y wget libpq-dev git-core postgresql-client build-essential --no-install-recommends

RUN mkdir /app
WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN bundle install
WORKDIR /app
CMD bundle exec rails server -b0.0.0.0
