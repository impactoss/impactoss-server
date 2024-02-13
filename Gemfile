# frozen_string_literal: true

source "https://rubygems.org"
ruby file: ".ruby-version"

gem "batch_api"
gem "bcrypt", "~> 3.1.7"
gem "clockwork"
gem "devise"
gem "devise_token_auth", "~> 1.2"
gem "omniauth-azure-activedirectory-v2", "~> 2.1.0"
gem "foundation-rails"
gem "fog-aws"
gem "jquery-rails"
gem "jsonapi-serializer"
gem "kaminari"
gem "net-smtp"
gem "paper_trail"
gem "pg", "~> 1.2"
gem "puma", "~> 5.5"
gem "pundit"
gem "rack-cors", require: "rack/cors"
gem "rails", "~> 6.0"
gem "sass-rails", "~> 6.0"
gem "secure_headers", ">= 3.0"

group :production, :staging do
  gem "net-pop"
  gem "net-imap"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "bundler-audit", require: false
  gem "letter_opener_web"
  gem "listen"
  gem "overcommit"
  gem "simplecov", require: false
  gem "spring"
  gem "standard"
  gem "thin", require: false
  gem "web-console", "~> 4.1"
end

group :development, :test do
  gem "awesome_print"
  gem "brakeman"
  gem "byebug"
  gem "dotenv-rails"
  gem "factory_bot_rails", "~> 6.0"
  gem "faker"
  gem "i18n-tasks", "~> 0.9.6"
  gem "rspec-rails"
end

group :test do
  gem "capybara"
  gem "connection_pool"
  gem "database_cleaner"
  gem "launchy"
  gem "pry-rails"
  gem "shoulda-matchers"
  gem "timecop"
end
