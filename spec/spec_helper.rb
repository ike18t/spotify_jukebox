require 'sinatra'
require 'rack/test'
require 'rspec'
require 'pry'
require 'autotest'
require 'mocha/api'

ENV['RACK_ENV'] = 'test'

files = Dir.glob('app/**/*.rb')
files.each{ |file| require File.expand_path("#{file}"); }

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
