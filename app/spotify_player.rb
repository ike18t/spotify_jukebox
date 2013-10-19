#!/usr/bin/env ruby

require_relative 'common'
require_relative 'session_wrapper'
require 'json'

class SpotifyPlayer

  SP_IMAGE_SIZE_NORMAL = 0
  attr_accessor :session_wrapper
  def initialize
    @session_wrapper = $session_wrapper
  end

  def play_track(track)
    $logger.info "I'm going to play a track now"
    poll(@session_wrapper.session) { Spotify.track_is_loaded(track) }
    Spotify.try(:session_player_play, @session_wrapper.session, false)
    Spotify.try(:session_player_load, @session_wrapper.session, track)
    Spotify.try(:session_player_play, @session_wrapper.session, true)
    $end_of_track = false
  end

  def log_metadata(track, who_added) track_name     = Spotify.track_name track
    artists        = (0..Spotify.track_num_artists(track) - 1).map{|i| Spotify.artist_name(Spotify.track_artist track, i)}
    album_name     = Spotify.album_name(Spotify.track_album(track))
    album_cover_id = Spotify.album_cover(Spotify.track_album(track), SP_IMAGE_SIZE_NORMAL)
    image_hex = if album_cover_id
                  album_cover_id.unpack('H40')[0]
                end
    $logger.info "Now playing #{track_name} by #{artists.join(", ")} on the album #{album_name}"
    $logger.info "spotify image hex: #{image_hex}"
    $metadata = {
                  :track_name => track_name,
                  :artists    => artists.join(", "),
                  :album_name => album_name,
                  :image      => image_hex,
                  :adder      => who_added
                 }
  end

  def get_playlist
    link = Spotify.link_create_from_string $playlist_uri

    playlist = Spotify.playlist_create @session_wrapper.session, link

    poll(@session_wrapper.session) { Spotify.playlist_is_loaded(playlist) }
    playlist
  end

  def start!
    playlist = get_playlist

    $logger.info "there are #{Spotify.playlist_num_tracks(playlist)} songs"
    loop do
      random_track_index = rand(Spotify.playlist_num_tracks(playlist)) - 1
      creator = Spotify.playlist_track_creator(playlist, random_track_index)
      who_added = Spotify.user_canonical_name creator

      $logger.info "this song was added by #{who_added}"

      enabled = CacheHandler.get_enabled_users
      if enabled.include? who_added or enabled.empty?
        track = Spotify.playlist_track(playlist, random_track_index)
        play_track(track)
        log_metadata(track, who_added)
        poll(@session_wrapper.session) { $end_of_track }
      else
        $logger.info "#{who_added} is currently disabled. skipping to next song"
      end
    end
  end
end
