require 'bundler'
require 'bundler/setup'
require 'logger'
require 'rspec/core/rake_task'
require 'thin'

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

RSpec::Core::RakeTask.new :spec

task :default => :spec

APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__)))
SINATRA_PORT = 4567
PLAYER_ENDPOINT = 'http://localhost:%s/player_endpoint'

log_file = File.open('spotify_jukebox.log', 'w')
$logger = Logger.new(MultiIO.new(STDOUT, log_file))
$logger.level = Logger::INFO

desc 'Starts the JukeBox web server.'
task :start_web do
  JukeboxWeb.run!({ :server => 'thin', :port => SINATRA_PORT })
end

desc 'Starts the JukeBox player.'
task :start_player do
  player_update_endpoint = PLAYER_ENDPOINT % SINATRA_PORT
  JukeboxPlayer.new(player_update_endpoint).start!
end

desc 'Creates the database and required tables.'
task :db_init do
  require 'sqlite3'
  db = SQLite3::Database.new('jukebox.db')
  db.execute('CREATE TABLE key_value_store( key CHAR(100) PRIMARY KEY NOT NULL, value BLOB NOT NULL );')
end

desc 'Starts both the JukeBox player and the web server.'
task :start do
  # Kill main thread if any other thread dies.
  Thread.abort_on_exception = true

  Thread.new do
    Rake::Task[:start_player].execute
  end
  Rake::Task[:start_web].execute
end

desc 'Clears the track historian.'
task :clear_historian do
  CacheService.clear_track_history!
end

