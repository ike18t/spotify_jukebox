#!/usr/bin/env ruby

require_relative 'common'
require_relative 'session_wrapper'
require 'json'

class JukeboxPlayer

  SP_IMAGE_SIZE_NORMAL = 0
  attr_accessor :session_wrapper
  def initialize
    @session_wrapper = $session_wrapper
  end

  def start!
    playlist = get_playlist

    current_user = nil
    loop do
      enabled_users = CacheHandler.get_enabled_users
      if enabled_users.empty?
        rando = get_random_track playlist
        current_user = rando[:user]
        track = rando[:track]
      else
        current_user = get_next_user enabled_users, current_user
        track = get_random_track_for_user playlist, current_user
      end
      next if track.nil?
      play_track(track)
      log_metadata(track, current_user)
      poll(@session_wrapper.session) { $end_of_track }
    end
  end

  private
  def play_track(track)
    poll(@session_wrapper.session) { Spotify.track_is_loaded(track) }
    Spotify.try(:session_player_play, @session_wrapper.session, false)
    Spotify.try(:session_player_load, @session_wrapper.session, track)
    Spotify.try(:session_player_play, @session_wrapper.session, true)
    $end_of_track = false
  rescue Spotify::Error => e
    if e.message =~ /^\[TRACK_NOT_PLAYABLE\]/
      $end_of_track = true
    else
      throw
    end
  end

  def log_metadata(track, who_added)
    track_name     = Spotify.track_name track
    artists        = (0..Spotify.track_num_artists(track) - 1).map{|i| Spotify.artist_name(Spotify.track_artist track, i)}
    album_name     = Spotify.album_name(Spotify.track_album(track))
    album_cover_id = Spotify.album_cover(Spotify.track_album(track), SP_IMAGE_SIZE_NORMAL)
    image_hex = if album_cover_id
                  album_cover_id.unpack('H40')[0]
                end
    $logger.info "Now playing #{track_name} by #{artists.join(", ")} on the album #{album_name}"
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

  def get_tracks_for_user playlist, user
    tracks = []
    num_tracks = Spotify.playlist_num_tracks(playlist)
    (0..num_tracks-1).each do |index|
      track = Spotify.playlist_track(playlist, index)
      added_by = Spotify.playlist_track_creator(playlist, index)
      tracks << track if Spotify.user_canonical_name(added_by) == user
    end
    tracks
  end

  def get_random_track_for_user playlist, user
    tracks = get_tracks_for_user playlist, user
    tracks.sample
  end

  def get_random_track playlist
    random_track_index = rand(Spotify.playlist_num_tracks(playlist)) - 1
    creator = Spotify.playlist_track_creator(playlist, random_track_index)
    added_by = Spotify.user_canonical_name creator
    { :user => added_by, :track => Spotify.playlist_track(playlist, random_track_index) }
  end

  def get_next_user enabled_users, last_user
    last_index = enabled_users.index(last_user) || rand(enabled_users.count)-1
    enabled_users.rotate! last_index + 1
    enabled_users.first
  end

end
