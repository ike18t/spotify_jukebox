#!/usr/bin/env ruby

require_relative 'common'
require 'json'
require 'plaything'

SP_IMAGE_SIZE_NORMAL = 0
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

def play_track(track)
  $logger.info "I'm going to play a track now"
  poll($session) { Spotify.track_is_loaded(track) }
  Spotify.try(:session_player_play, $session, false)
  Spotify.try(:session_player_load, $session, track)
  Spotify.try(:session_player_play, $session, true)
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
  File.open('metadata.yml', 'w') do |file|
    file.write({ 'track_name' => track_name,
                 'artists'    => artists.join(", "),
                 'album_name' => album_name,
                 'image'      => image_hex,
                 'adder'      => who_added}.to_yaml)
  end
end

class FrameReader
  include Enumerable

  def initialize(channels, sample_type, frames_count, frames_ptr)
    @channels = channels
    @sample_type = sample_type
    @size = frames_count * @channels
    @pointer = FFI::Pointer.new(@sample_type, frames_ptr)
  end

  attr_reader :size

  def each
    return enum_for(__method__) unless block_given?

    ffi_read = :"read_#{@sample_type}"

    (0...size).each do |index|
      yield @pointer[index].public_send(ffi_read)
    end
  end
end

plaything = Plaything.new

#
# Global callback procs.
#
# They are global variables to protect from ever being garbage collected.
#
# You must not allow the callbacks to ever be garbage collected, or libspotify
# will hold information about callbacks that no longer exist, and crash upon
# calling the first missing callback. This is *very* important!

$session_callbacks = {
  log_message: proc do |session, message|
    $logger.debug('session (log message)') { message }
  end,

  logged_in: proc do |session, error|
    $logger.info('session (logged in)') { Spotify::Error.explain(error) }
  end,

  logged_out: proc do |session|
    $logger.debug('session (logged out)') { 'logged out!' }
  end,

  streaming_error: proc do |session, error|
    $logger.error('session (player)') { 'streaming error %s' % Spotify::Error.explain(error) }
  end,

  start_playback: proc do |session|
    $logger.debug('session (player)') { 'start playback' }
    plaything.play
  end,

  stop_playback: proc do |session|
    $logger.debug('session (player)') { 'stop playback' }
    plaything.stop
  end,

  get_audio_buffer_stats: proc do |session, stats|
    stats[:samples] = plaything.queue_size
    stats[:stutter] = plaything.drops
    $logger.debug('session (player)') { "queue size [#{stats[:samples]}, #{stats[:stutter]}]" }
  end,

  music_delivery: proc do |session, format, frames, num_frames|
    if num_frames == 0
      plaything.stop
      $logger.debug('session (player)') { "music delivery audio discontuity" }
    else
      frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
      consumed_frames = plaything.stream(frames, format.to_h)
      $logger.debug('session (player)') { "#{format.to_h}" }
      $logger.debug('session (player)') { "music delivery #{consumed_frames} of #{num_frames}" }
      consumed_frames
    end
  end,

  end_of_track: proc do |session|
    $end_of_track = true
    $logger.debug('session (player)') { 'end of track' }
    plaything.stop
  end,
}

# not currently using
$playlist_callbacks = {
  playlist_state_changed: proc do |playlist, user|
    $track_count = Spotify.playlist_num_tracks(playlist)
    if Spotify.playlist_is_loaded playlist
      $logger.info "playlist loaded with #{$track_count} tracks"
      track = Spotify.playlist_track playlist, rand($track_count)
      $logger.info 'about to play song from playlist_state_change'
      playlist_track track
    end
  end
}

#
# Main work code.
#

# You can read about what these session configuration options do in the
# libspotify documentation:
# https://developer.spotify.com/technologies/libspotify/docs/12.1.45/structsp__session__config.html
config = Spotify::SessionConfig.new({
  api_version: Spotify::API_VERSION.to_i,
  application_key: $appkey,
  cache_location: '../.spotify/',
  settings_location: '../.spotify/',
  tracefile: '../spotify_tracefile.txt',
  user_agent: 'spotify for ruby',
  callbacks: Spotify::SessionCallbacks.new($session_callbacks),
})

$logger.info "Creating session."
FFI::MemoryPointer.new(Spotify::Session) do |ptr|
  Spotify.try(:session_create, config, ptr)
  $session = Spotify::Session.new(ptr.read_pointer)
end

$logger.info "Created! Logging in."
Spotify.session_login($session, $username, $password, false, nil)

$logger.info "Log in requested. Waiting forever until logged in."
poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}."
link = Spotify.link_create_from_string "spotify:user:1215286433:playlist:0Ur8JSOQMuu3HWj4G63S42"
$playlist = Spotify.playlist_create $session, link

poll($session) { Spotify.playlist_is_loaded($playlist) }
$logger.info "there are #{Spotify.playlist_num_tracks($playlist)} songs"
loop do
  random_track_index = rand(Spotify.playlist_num_tracks($playlist)) - 1
  creator = Spotify.playlist_track_creator($playlist, random_track_index)
  who_added = Spotify.user_canonical_name creator

  $logger.info "this song was added by #{who_added}"

  enabled = CacheHandler.get_enabled_users
  if enabled.include? who_added or enabled.empty?
    track = Spotify.playlist_track($playlist, random_track_index)
    play_track(track)
    log_metadata(track, who_added)
    poll($session) { $end_of_track }
  else
    $logger.info "#{who_added} is currently disabled. skipping to next song"
  end
end
