FROM ruby:2.3.3-slim
ENV PORT 3000
EXPOSE $PORT

# Run as root to install dependencies and set up user
RUN apt-get update -qq &&\
    apt-get install -y curl libpq-dev git-core postgresql-client build-essential --no-install-recommends &&\
    curl -sL https://deb.nodesource.com/setup_4.x | bash - &&\
    apt-get install -y nodejs

RUN adduser deploy && mkdir /app && chown -R deploy /app/

# Run as the 'deploy' user
USER deploy
WORKDIR /app
ADD . /app
RUN bundle install
CMD bundle exec rails server -b0.0.0.0 -p $PORT
