require 'sinatra'
require 'rack/test'
require 'rspec'
require 'pry'
require 'autotest'
require 'mocha/api'
require_relative 'mock_logger'

ENV['RACK_ENV'] = 'test'

file = File.join(File.dirname(__FILE__), '../app')
files = Dir.glob("#{file}/**/*.rb")
files.each{ |file| require file }

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
