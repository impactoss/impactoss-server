source "https://rubygems.org"
ruby "2.3.1"

gem "rails", "5.0.0"
gem "bcrypt", "~> 3.1.7"
gem "jquery-rails"
gem "pg", "~> 0.18"
gem "sass-rails", "~> 5.0"
gem "secure_headers", ">= 3.0"
gem "devise"
gem "foundation-rails"

group :production, :staging do
  gem "unicorn"
  gem "unicorn-worker-killer"
end

group :development do
  gem "awesome_print"
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener_web"
  gem "web-console", "~> 2.0"
  gem "spring"
  gem "listen"
end

group :development do
  gem "bundler-audit", :require => false
  gem "simplecov", :require => false
  gem "thin", :require => false
  gem "rubocop", :require => false
end

group :development, :test do
  gem "rspec-rails"
  gem "dotenv-rails"
  gem "brakeman"
  gem "factory_girl_rails"
  gem "faker"
end

group :test do
  gem "capybara"
  gem "connection_pool"
  gem "launchy"
  gem "pry-rails"
  gem "database_cleaner"
  gem "poltergeist"
end
