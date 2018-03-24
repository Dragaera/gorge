$LOAD_PATH.unshift 'lib'

APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

# Ignore all uninitialized instance variable warnings
Warning.ignore(/instance variable @\w+ not initialized/)

Dotenv.load(".env.#{ APPLICATION_ENV }")

require 'gorge'

require 'config/gorge'
require 'config/database'

unless ENV['GORGE_SKIP_MODELS'] == '1'
  # Has to be loaded after DB is ready.
  require 'gorge/models'
end

Typhoeus::Config.user_agent = 'Gorge (https://github.com/Dragaera/gorge)'
