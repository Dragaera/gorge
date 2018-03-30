# coding: utf-8

require 'config/boot'

require 'resque/server'
require 'resque/scheduler/server'
require 'resque-job-stats/server'

url_map = {
  '/' => Gorge::Web::API
}

resque_web_path = Gorge::Config::Resque::WEB_PATH
url_map[resque_web_path] = Resque::Server.new if resque_web_path

run Rack::URLMap.new(url_map)
