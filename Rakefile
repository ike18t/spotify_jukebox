require 'bundler'
require 'bundler/setup'
require_relative './app/jukebox_web'
require_relative './app/jukebox_player'
require_relative './app/common'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

task :default => :spec

task :start do
  $session_wrapper = SessionWrapper.new
  Thread.new do
    JukeboxPlayer.new.start!
  end
  JukeboxWeb.run!({ :server => 'thin' })
end
