# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'selenium/webdriver'
require_relative 'spec_support/capybara_extensions'

ActiveRecord::Migration.maintain_test_schema!

Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include CapybaraExtensions, type: :system

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome
  end
end
