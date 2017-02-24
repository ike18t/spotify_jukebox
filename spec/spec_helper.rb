require_relative 'mock_logger'
require 'webmock/rspec'

Bundler.require :default, :test

ENV['RACK_ENV'] = 'test'

SimpleCov.start

require_all 'app'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.after(:each) do
    CacheService.clear
  end
end

JukeboxWeb.set(
  environment: :test,
  run: false,
  raise_errors: true,
  logging: false
)

$logger = MockLogger.new

SQLite3Adapter.const_set(:DATABASE, 'jukebox_test.db')

class CacheService
  def self.clear
    @@data_store = {}
  end

  def self.data_store
    @@data_store ||= {}
  end
end
