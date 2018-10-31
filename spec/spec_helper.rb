# frozen_string_literal: true

require 'dotenv/load'
require 'typhoeus'
require 'vcr'
require 'pry'

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start('rails') do
    add_group 'Decorators', 'app/decorators'
    add_group 'Entities', 'app/entities'
    add_group 'Forms', 'app/forms'
    add_group 'Mappers', 'app/mappers'
    add_group 'Operations', 'app/operations'
    add_group 'View-models', 'app/view_models'
  end
end

require_relative 'spec_support/scrub_query_params'

%w[app/entities app/lib app/operations app/mappers].each do |dir|
  $LOAD_PATH << File.expand_path(dir)
end

VCR.configure do |config|
  dateless_uri_matcher = lambda do |request1, request2|
    uri1 = ScrubQueryParams.scrub(request1.uri, %w[from to date])
    uri2 = ScrubQueryParams.scrub(request2.uri, %w[from to date])

    uri1 == uri2
  end

  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :typhoeus
  config.configure_rspec_metadata!
  config.register_request_matcher :dateless_uri, &dateless_uri_matcher

  config.filter_sensitive_data('<CLIENT_ID>') do
    ENV.fetch('CLIENT_ID')
  end
  config.filter_sensitive_data('<CLIENT_SECRET>') do
    ENV.fetch('CLIENT_SECRET')
  end
  config.filter_sensitive_data('<TEST_ACCESS_TOKEN>') do
    ENV.fetch('TEST_ACCESS_TOKEN')
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
