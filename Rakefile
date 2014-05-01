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

task :start do
  APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__)))

  # Kill main thread if any other thread dies.
  Thread.abort_on_exception = true

  # We use a logger to print some information on when things are happening.
  log_file = File.open('spotify_jukebox.log', 'w')
  $logger = Logger.new(MultiIO.new(STDOUT, log_file))
  $logger.level = Logger::INFO

  message_queue = Queue.new
  Thread.new do
    JukeboxPlayer.new(message_queue, TrackHistorian.new).start!
  end
  JukeboxWeb.run!({ :server => 'thin', :custom => { :message_queue => message_queue }})
end
