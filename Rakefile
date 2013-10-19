require 'bundler'
require 'bundler/setup'
require_relative './app/jukebox_web'
require_relative './app/jukebox_player'
require_relative './app/common'

task :start do
  $session_wrapper = SessionWrapper.new
  Thread.new do
    JukeboxPlayer.new.start!
  end
  JukeboxWeb.run!
end
