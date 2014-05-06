require 'sinatra'
require 'rack/test'
require 'rspec'
require 'pry'
require 'autotest'
require_relative 'mock_logger'

ENV['RACK_ENV'] = 'test'

def autoload_all path
  Dir.glob("#{path}**/*.rb").each do |file|
    File.open(file, 'r') do |infile|
      while (line = infile.gets)
        match = line.match /^(class|module)\s([A-Z]\w+)/
        if not match.nil? and not match[2].nil?
          autoload match[2].to_sym, File.expand_path(file)
          break
        end
      end
    end
  end
end

autoload_all 'app/'

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
