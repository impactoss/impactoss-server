![IMPACT OSS](header.png?raw=true "IMPACT OSS")

# IMPACT OSS server application

This is the source code for the server-side application (the "API") of IMPACT OSS.

It is a **Rails 5.0.1 application** and is a thin server that is responsible for:
* database management and access via an API (Application Programming Interface)
* user authentication
* automated email reminders

##### IMPACT OSS client application

It complements the IMPACT OSS client-side application (the "UI") that you can find here: https://github.com/impactoss/impactoss-client

The client is a React JavaScript application and is a single page application that is responsible for:
* public User Interface (UI)
* admin UI

---

## About IMPACT OSS

IMPACT OSS is an Open Source Software (OSS) for Integrated Management and Planning of Actions (IMPACT), created to assist States with coordinating and monitoring implementation of human rights and the Sustainable Development Goals (SDGs).

The IMPACT OSS project is maintained by the Impact Open Source Software Trust. To learn more about the project and the Trust see https://impactoss.org

---

## Documentation

#### Configuration & Installation

The IMPACT OSS installation guide provides detailed instructions on how to configure and install both server and client applications:
https://install-guide.impactoss.org/

#### How to set up a development environment

##### Prerequisites

This project requires:

* Ruby 2.3.3, preferably managed using [rbenv][]
* PhantomJS (in order to use the [poltergeist][] gem)
* PostgreSQL must be installed and accepting connections

On a Mac, you can obtain all of the above packages using [Homebrew][]. If you wish to use Docker, the above dependencies will be provided by the Dockerfile and docker-compose file included in this repository.

If you need help setting up a Ruby development environment, check out this [Rails OS X Setup Guide](https://mattbrictson.com/rails-osx-setup-guide).

##### Configuration

###### Set up secrets

```
cp config/secrets-sample.yml config/secrets.yml
```

and edit. You can generate a new secret to use, like this:

```
rake secret
```

###### Set up Devise

```
cp config/initializers/devise-sample.rb config/initializers/devise.rb
```

Then edit to include a secret_key, example:

```
# rubocop:disable Metrics/LineLength
config.secret_key = 'your-secret-goes-here'
# rubocop:enable Metrics/LineLength
```

#### Code style

This project uses overcommit to enforce code style. To enable overcommit locally

```
gem install overcommit
overcommit -i
```

You'll need to sign the overcommit (verify you're happy with it executing).
Do this after installing, and again every time the overcommit config changes.

```
overcommit --sign
```

To install the extra linters, run
```
[sudo] pip install yamllint
npm install -g jshint
```

#### Getting started

##### With Docker

Run `docker-compose up` to create and start a DB and app image, with the app listening on port 3000. You will also need to run `docker-compose run app rake db:setup` to create and seed a development database. The app has several configuration value that can be set that are listed in the `example.env` file. You can either copy this file to `.env` and provide your own configuration, or explicitly pass in your configuration to the `docker run` command.

If you already have a database instance and just wish to run the app you will need to build the image:

`docker build . -t "undp-human-rights-national-reporting"`

And then run the resulting image:

`docker run undp-human-rights-national-reporting -P -e PGHOST=YOUR_DB_HOST -e PGUSER=YOUR_PG_USER`

##### Without Docker

Run the `bin/setup` script. This script will:

* Check you have the required Ruby version
* Install gems using Bundler
* Create local copies of `.env` and `database.yml`
* Create, migrate, and seed the database

##### Run it!

1. Run `rake spec` to make sure everything works.
2. Run `rails s` to start the Rails app.

[rbenv]:https://github.com/sstephenson/rbenv
[poltergeist]:https://github.com/teampoltergeist/poltergeist
[Homebrew]:http://brew.sh

---

## Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md)

---

## License

This project is licensed under the MIT license, see [LICENSE.md](LICENSE.md).
