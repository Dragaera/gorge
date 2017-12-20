APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

Dotenv.load(".env.#{ APPLICATION_ENV }")

require_relative 'gorge'
require_relative 'database'
