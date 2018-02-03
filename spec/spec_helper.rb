RSpec.configure do |config|
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
end
