require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'sinatra/asset_pipeline/task'

Bundler.require

require_all 'app'

Sinatra::AssetPipeline::Task.define! JukeboxWeb

RSpec::Core::RakeTask.new :spec

task default: [:spec, :js_spec]

APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__)))
SINATRA_PORT = 4567
PLAYER_ENDPOINT = 'http://localhost:%s/player_endpoint'.freeze

log_file = File.open('spotify_jukebox.log', 'w')
$logger = Logger.new(MultiIO.new(STDOUT, log_file))
$logger.level = Logger::INFO

desc 'Starts the JukeBox web server.'
task :start_web do
  JukeboxWeb.run!(server: 'thin', port: SINATRA_PORT)
end

desc 'Starts the JukeBox web server using the test db.'
task :start_test_web do
  ENV['TEST'] = 'true'
  JukeboxWeb.run!(server: 'thin', port: SINATRA_PORT)
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
  # rubocop:disable Lint/Debugger
  require 'pry'
  binding.pry
  # rubocop:enable Lint/Debugger
end

task :before_assets_precompile do
  commands = <<-DATA
    npm install
    npm run postinstall
    npm run build
  DATA
  Dir.chdir('frontend') do
    commands.lines.each do |command|
      sh(command)
    end
  end
end
# every time you execute 'rake assets:precompile'
# run 'before_assets_precompile' first
Rake::Task['assets:precompile'].enhance ['before_assets_precompile']

RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

desc 'Run the javascript specs.'
task :js_spec do
  commands = <<-DATA
    npm install
    npm run postinstall
    npm test
  DATA
  Dir.chdir('frontend') do
    commands.lines.each do |command|
      sh(command)
    end
  end
end
