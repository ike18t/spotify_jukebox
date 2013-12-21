require 'bundler'
require 'bundler/setup'
require 'logger'
require 'rspec/core/rake_task'
require 'thin'
require_relative './app/multi_io'
require_relative './app/jukebox_web'
require_relative './app/jukebox_player'
require_relative './app/track_historian'
require_relative './app/spotify_wrapper'
require_relative './app/config_service'

RSpec::Core::RakeTask.new :spec

task :default => :spec

task :start do
  APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__)))

  config = ConfigService.get

  # Kill main thread if any other thread dies.
  Thread.abort_on_exception = true

  # We use a logger to print some information on when things are happening.
  log_file = File.open('spotify_jukebox.log', 'w')
  $logger = Logger.new(MultiIO.new(STDOUT, log_file))
  $logger.level = Logger::INFO

  queue = { :web => Queue.new }
  spotify_wrapper = SpotifyWrapper.new config, queue
  Thread.new do
    JukeboxPlayer.new(spotify_wrapper, queue, config.playlist_uri, TrackHistorian.new).start!
  end
  JukeboxWeb.run!({ :server => 'thin', :custom => { :spotify_wrapper => spotify_wrapper, :queue => queue, :playlist_uri => config.playlist_uri }})
end
