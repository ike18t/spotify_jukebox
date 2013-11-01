require 'bundler'
require 'bundler/setup'
require 'logger'
require 'rspec/core/rake_task'
require 'pry'
require_relative './app/jukebox_web'
require_relative './app/jukebox_player'
require_relative './app/track_historian'
require_relative './app/session_wrapper'
require_relative './app/config_loader'

RSpec::Core::RakeTask.new :spec

task :default => :spec

task :start do
  APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__)))

  config = ConfigLoader.load

  # Kill main thread if any other thread dies.
  Thread.abort_on_exception = true

  # We use a logger to print some information on when things are happening.
  $logger = Logger.new('spotify_jukbox.log', 'daily')
  $logger.level = Logger::DEBUG

  queue = { :player => Queue.new, :web => Queue.new }
  session_wrapper = SessionWrapper.new config, queue
  Thread.new do
    JukeboxPlayer.new(session_wrapper, queue, config.playlist_uri, TrackHistorian.new).start!
  end
  JukeboxWeb.run!({ :server => 'thin', :custom => { :session_wrapper => session_wrapper, :queue => queue, :playlist_uri => config.playlist_uri }})
end
