ENV['JWT_SECRET'] = 'someawesomesecret'
ENV['JWT_ISSUER'] = 'onboarding'

require File.join(File.dirname(__FILE__), '..', 'server.rb')

require 'rspec'

require 'simplecov'
require 'factory_bot'
require 'rack/test'
require 'database_cleaner/active_record'
require 'shoulda-matchers'
require_relative './helpers/user_helper'

SimpleCov.start

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expose_dsl_globally = true
  config.include FactoryBot::Syntax::Methods
  config.include UserHelpers
  config.before(:suite) do
    FactoryBot.find_definitions
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before :each do
    DatabaseCleaner.start
    FactoryBot.reload
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
  end
end
