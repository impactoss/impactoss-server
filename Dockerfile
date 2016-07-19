FROM ruby:2.3.1-slim
ENV PHANTOM_JS_VERSION 2.1.1
ENV PHANTOM_JS_PACKAGE phantomjs-$PHANTOM_JS_VERSION-linux-x86_64
ENV PORT 3000
EXPOSE 3000

RUN apt-get update -qq &&\
    apt-get install -y curl libpq-dev git-core postgresql-client build-essential --no-install-recommends &&\
    curl -sL https://deb.nodesource.com/setup_4.x | bash - &&\
    apt-get install -y nodejs

RUN mkdir /app
RUN bundle install
WORKDIR /app
CMD bundle exec rails server -b0.0.0.0
CMD bundle exec rails server -b0.0.0.0 -p $PORT
