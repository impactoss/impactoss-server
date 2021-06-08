# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.6.6'

gem 'active_model_serializers'
gem 'batch_api'
gem 'bcrypt', '~> 3.1.7'
gem 'clockwork'
gem 'devise'
gem 'devise_token_auth'
gem 'factory_girl_rails'
gem 'faker'
gem 'fast_jsonapi', git: 'https://github.com/Netflix/fast_jsonapi',
                    branch: 'dev'
gem 'foundation-rails'
gem 'fog-aws'
gem 'jquery-rails'
gem 'kaminari'
gem 'oj'
gem 'paper_trail'
gem 'pg', '~> 0.18'
gem 'pundit'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 6.0'
gem 'sass-rails', '~> 5.0'
gem 'secure_headers', '>= 3.0'

group :production, :staging do
  gem 'unicorn'
  gem 'unicorn-worker-killer'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bundler-audit', require: false
  gem 'letter_opener_web'
  gem 'listen'
  gem 'overcommit'
  gem 'simplecov', require: false
  gem 'spring'
  gem 'thin', require: false
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman'
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'i18n-tasks', '~> 0.9.6'
  gem 'rspec-rails'
  gem 'rubocop', require: false
end

group :test do
  gem 'capybara'
  gem 'connection_pool'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'shoulda-matchers'
  gem 'timecop'
end
