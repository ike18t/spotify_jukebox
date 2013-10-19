require 'bundler'
require 'bundler/setup'
require_relative './app/spotify_jukebox'
require_relative './app/spotify_player'
require_relative './app/common'

task :start do
  $session_wrapper = SessionWrapper.new
  Thread.new do
    SpotifyPlayer.new.start!
  end
	SpotifyJukebox.run!
end
