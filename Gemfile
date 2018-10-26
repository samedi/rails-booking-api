# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) do |repo|
  "https://github.com/#{repo}.git"
end

ruby '2.5.1'

# Essential stack
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.1'

# Infrastructure
gem 'bootsnap', '>= 1.1.0', require: false

# Authentication
gem 'omniauth', '~> 1.8.0'

# Views and front-end
gem 'haml-rails', '~> 1.0'
gem 'jbuilder', '~> 2.5'
gem 'simple_form', '~> 4.0'
gem 'webpacker', '~> 3.0'

# HTTP clients
gem 'addressable', '~> 2.5.2'
gem 'faraday', '~> 0.15.0'
gem 'faraday_middleware', '~> 0.12.0'
gem 'typhoeus', '~> 1.3.0'

# Monitoring
gem 'rollbar'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'guard-rspec', '~> 4.7'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.7'
end

group :development do
  gem 'guard-rubocop', '~> 1.3'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
  gem 'yard'
end

group :test do
  gem 'capybara', '~> 3.8'
  gem 'chromedriver-helper', '~> 2.1'
  gem 'selenium-webdriver', '~> 3.14'
  gem 'vcr', '~> 4.0'

  gem 'simplecov', '~> 0.16', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
