web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -v
postdeploy: bundle exec rails db:prepare
