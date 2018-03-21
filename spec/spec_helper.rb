$LOAD_PATH.unshift '.'

ENV['APPLICATION_ENV'] = 'testing'

# Ugly, but we have to ensure it's set before the rest of the application is loaded, as:
# - some loggers (`config/database.rb`) are defined in the top-level of a file
# - some loggers (`lib/gorge/web/*`) are defined on class-level
# and will therefore be evaluated upon the file being required - at which point
# we would have had no chance to set the default logger.
require 'gorge/logger'
Gorge.default_logger_cls = Gorge::NullLogger

require 'config/boot'
require 'helpers'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    # RSpec 4
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Only allow stubbing/mocking existing method.
    mocks.verify_partial_doubles = true
  end

  # RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # If any tagged with :focus, run only those.
  config.filter_run_when_matching :focus

  # Persistent state
  config.example_status_persistence_file_path = "spec/examples.txt"

  # No monkey-patched syntax.
  config.disable_monkey_patching!

  config.warnings = true

  # Print 10 slowest specs
  config.profile_examples = 10

  config.order = :random
  # Allow specifying seed
  Kernel.srand config.seed

  config.before(:suite) do
    FactoryBot.find_definitions

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, except: ['teams'])
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  def app
    Gorge::Web::API.new
  end

  config.include Gorge::Helpers::DatabaseHelpers
end
