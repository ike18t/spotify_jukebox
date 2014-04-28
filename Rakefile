require 'bundler'
require 'bundler/setup'
require 'logger'
require 'rspec/core/rake_task'
require 'thin'
require 'autoload_for'
require_relative 'app/multi_io'

include AutoloadFor
autoload_for './app'

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

  message_queue = Queue.new
  spotify_wrapper = SpotifyWrapper.new config
  Thread.new do
    JukeboxPlayer.new(spotify_wrapper, message_queue, config.playlist_uri, TrackHistorian.new).start!
  end
  JukeboxWeb.run!({ :server => 'thin', :custom => { :spotify_wrapper => spotify_wrapper, :message_queue => message_queue, :playlist_uri => config.playlist_uri }})
end
