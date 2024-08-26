# syntax = docker/dockerfile:1

ARG NODE_VERSION=20.14.0
# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.1
FROM node:${NODE_VERSION}-bookworm-slim as node_base
FROM ruby:${RUBY_VERSION}-slim as base

# Rails app lives here
WORKDIR /app

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    apt-utils \
    bash \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips \
    make \
    openssh-client \
    postgresql-client-15 \
    pkg-config \
    pv \
    tini \
    zsh

COPY --from=node_base /usr/local/bin /usr/local/bin
COPY --from=node_base /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/npm

# Set development environment
ENV BUNDLE_DEPLOYMENT="0" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="" \
    BUNDLE_JOBS=8

# Install Bundler
RUN gem install bundler -v 2.5.18

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version .
RUN bundle check || bundle install

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Copy application code
COPY . .

RUN git config --global --add safe.directory /app

# Set tini as the entry point and run the app through it
ENTRYPOINT ["/usr/bin/tini", "--"]

# Set default command to run, which will now run through tini
CMD ["zsh"]
