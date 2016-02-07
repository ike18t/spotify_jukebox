require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'rubocop/rake_task'
require 'sinatra/asset_pipeline/task'

Bundler.require

require_all 'app'

Sinatra::AssetPipeline::Task.define! JukeboxWeb

RSpec::Core::RakeTask.new :spec

task :default => [:rubocop, :spec, 'jasmine:ci']

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

desc 'Starts the JukeBox web server using the test db.'
task :start_test_web do
  ENV['TEST'] = 'true'
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

desc 'Creates the test database and required tables.'
task :test_db_init do
  require 'sqlite3'
  db = SQLite3::Database.new('test_jukebox.db')
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

desc 'Pry into application.'
task :pry do
  require 'pry'
  binding.pry
end

Cucumber::Rake::Task.new do |t|
  `rm test_jukebox.db`
  Rake::Task[:test_db_init].execute
  t.cucumber_opts = %w{--format pretty}
end

ENV['JASMINE_CONFIG_PATH'] = 'spec/js/support/jasmine.yml'
require 'jasmine'
require_relative 'spec/js/support/jasmine.rb'
load 'jasmine/tasks/jasmine.rake'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['app/**/*.rb', 'spec/**/*.rb']
  task.fail_on_error = true
end
