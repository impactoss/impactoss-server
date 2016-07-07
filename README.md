# human-rights-national-reporting

This is a Rails 5.0.0 app.

[ ![Codeship Status for rabid/undp-human-rights-national-reporting](https://codeship.com/projects/0278cdb0-2525-0134-bb7e-0e3391f87f23/status?branch=master)](https://codeship.com/projects/161691)

## Documentation

This README describes the purpose of this repository and how to set up a development environment. Other sources of documentation are as follows:

* UI and API designs are in `doc/`
* Server setup instructions are in `PROVISIONING.md`
* Staging and production deployment instructions are in `DEPLOYMENT.md`

## Prerequisites

This project requires:

* Ruby 2.3.1, preferably managed using [rbenv][]
* PhantomJS (in order to use the [poltergeist][] gem)
* PostgreSQL must be installed and accepting connections

On a Mac, you can obtain all of the above packages using [Homebrew][].

If you need help setting up a Ruby development environment, check out this [Rails OS X Setup Guide](https://mattbrictson.com/rails-osx-setup-guide).

## Getting started

### bin/setup

Run the `bin/setup` script. This script will:

* Check you have the required Ruby version
* Install gems using Bundler
* Create local copies of `.env` and `database.yml`
* Create, migrate, and seed the database

### Run it!

1. Run `rake spec` to make sure everything works.
2. Run `rails s` to start the Rails app.

[rbenv]:https://github.com/sstephenson/rbenv
[poltergeist]:https://github.com/teampoltergeist/poltergeist
[Homebrew]:http://brew.sh