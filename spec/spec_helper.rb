require_relative 'mock_logger'

Bundler.require :default, :test

ENV['RACK_ENV'] = 'test'
CodeClimate::TestReporter.start

require_all 'app'

JukeboxWeb.set(
  :environment => :test,
  :run => false,
  :raise_errors => true,
  :logging => false
)

module TestHelper
  def app
    JukeboxWeb.new
  end

  def body
    last_response.body
  end

  def status
    last_response.status
  end

  include Rack::Test::Methods
end

$logger = MockLogger.new

class CacheService
  def self.data_store
    @@data_store ||= {}
  end
end
