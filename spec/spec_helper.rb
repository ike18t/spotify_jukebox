require_relative 'mock_logger'

Bundler.require :default, :test

ENV['RACK_ENV'] = 'test'

SimpleCov.start

require_all 'app'

RSpec.configure do |config|
  config.include Rack::Test::Methods
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
  def self.data_store
    @@data_store ||= {}
  end
end
