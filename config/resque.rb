require 'yaml'

opts = {
  host: Gorge::Config::Redis::HOST
}
opts[:port] = Gorge::Config::Redis::PORT if Gorge::Config::Redis::PORT

Resque.redis = Redis.new(**opts)
Resque.schedule = YAML.load_file('config/resque_schedule.yml')
