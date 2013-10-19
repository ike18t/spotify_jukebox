require 'bundler/setup'
require 'spotify'
require 'logger'
require 'pry'
require 'yaml'
require_relative 'cache_handler'

# Kill main thread if any other thread dies.
Thread.abort_on_exception = true

# We use a logger to print some information on when things are happening.
$logger = Logger.new($stderr)
$logger.level = Logger::INFO

#
# Some utility.
#

# libspotify supports callbacks, but they are not useful for waiting on
# operations (how they fire can be strange at times, and sometimes they
# might not fire at all). As a result, polling is the way to go.
def poll(session)
  until yield
    FFI::MemoryPointer.new(:int) do |ptr|
      Spotify.session_process_events(session, ptr)
    end
    sleep(0.1)
  end
end

# Load the configuration.
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$appkey = IO.read(File.join(APP_ROOT, 'keys/spotify_appkey.key'), encoding: 'BINARY')
config = YAML.load_file('config.yml')
$username = config['username']
$password = config['password']
$playlist_uri = config['playlist_uri']
