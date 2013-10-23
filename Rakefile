require 'bundler'
require 'bundler/setup'
require_relative './app/jukebox_web'
require_relative './app/jukebox_player'
require_relative './app/track_historian'
require_relative './app/common'
require_relative './app/session_wrapper'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

task :default => :spec

task :start do
  $session_wrapper = SessionWrapper.new
  @track_historian = TrackHistorian.new
  Thread.new do
    JukeboxPlayer.new($session_wrapper, @track_historian).start!
  end
  JukeboxWeb.run!({ :server => 'thin' })
end
