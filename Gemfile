source 'https://rubygems.org'

gem 'sentry-raven'

gem 'sequel'
gem 'pg'
gem 'sequel_pg', require: 'sequel'
gem 'sqlite3'

gem 'typhoeus'

gem 'resque', require: ['resque', 'resque/failure/multiple', 'resque/failure/redis']
gem 'resque-scheduler'
gem 'resque-job-stats'
gem 'resque-sentry'

gem 'grape'
gem 'grape_logging'
gem 'puma'
gem 'shotgun'

gem 'rake'

gem 'warning'

gem 'uuid'

group :development do
  gem 'ruby-prof'
  gem 'yard'
end

group :development, :testing do
  gem 'dotenv'
  gem 'pry'
  gem 'pry-byebug'
end

group :testing do
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'timecop'
end
