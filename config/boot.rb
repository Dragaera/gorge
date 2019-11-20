$LOAD_PATH.unshift 'lib'

APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

# Ignore all uninitialized instance variable warnings
Warning.ignore(/instance variable @\w+ not initialized/)

Dotenv.load(".env.#{ APPLICATION_ENV }") if ['development', 'testing'].include? APPLICATION_ENV

# Needed by eg database config
require 'gorge/logger'
logger = Gorge.logger(module_: 'boot')

require 'config/gorge'
require 'config/database'
require 'config/resque'

# Needs access to Gorge::Config
require 'gorge'

unless ENV['GORGE_SKIP_MODELS'] == '1'
  # Has to be loaded after DB is ready.
  require 'gorge/models'
end

Typhoeus::Config.user_agent = 'Gorge (https://github.com/Dragaera/gorge)'

if Gorge::Config::Sentry.enabled?
  logger.info 'Configuring sentry integration.'

  Raven.configure do |config|
    config.dsn = Gorge::Config::Sentry::DSN
    config.release = Gorge::VERSION
    config.current_environment = APPLICATION_ENV
  end
else
  logger.info 'Skipping sentry integration configuration.'
end
