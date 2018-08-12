require 'yaml'

opts = {
  host: Gorge::Config::Redis::HOST
}
opts[:port] = Gorge::Config::Redis::PORT if Gorge::Config::Redis::PORT

Resque.redis = Redis.new(**opts)
Resque.schedule = YAML.load_file('config/resque_schedule.yml')

if Gorge::Config::Sentry.enabled?
  puts 'Enabling resque sentry integration.'

  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Sentry]
  Resque::Failure.backend = Resque::Failure::Multiple
else
  puts 'Skipping resque sentry integration.'
end
