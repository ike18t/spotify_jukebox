require 'bundler/setup'
require 'logger'
require 'pry'
require 'yaml'
require_relative 'cache_handler'

# Kill main thread if any other thread dies.
Thread.abort_on_exception = true

# We use a logger to print some information on when things are happening.
$logger = Logger.new($stderr)

# Load the configuration.
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$appkey = IO.read(File.join(APP_ROOT, 'keys/spotify_appkey.key'), encoding: 'BINARY')
config = YAML.load_file('config.yml')
$username = config['username']
$password = config['password']
$playlist_uri = config['playlist_uri']
