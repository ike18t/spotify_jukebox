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

log_file = File.open('spotify_jukebox.log', 'w')
$logger = Logger.new(MultiIO.new(STDOUT, log_file))
$logger.level = Logger::INFO

@message_queue = Queue.new

task :start_web_only do
  JukeboxWeb.run!({ :server => 'thin', :custom => { :message_queue => @message_queue }})
end

task :start_player_only do
  JukeboxPlayer.new(@message_queue, TrackHistorian.new).start!
end

task :start do
  # Kill main thread if any other thread dies.
  Thread.abort_on_exception = true

  Thread.new do
    Rake::Task[:start_player_only].execute
  end
  Rake::Task[:start_web_only].execute
end

