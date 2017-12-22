APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

Dotenv.load(".env.#{ APPLICATION_ENV }")

require 'gorge'

require 'config/gorge'
require 'config/database'

# Has to be loaded after DB is ready.
require 'gorge/models'
