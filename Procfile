web: bundle exec rails server thin -p $PORT
worker: bundle exec sidekiq -c 5 -v
clock: bundle exec clockwork scheduler.rb