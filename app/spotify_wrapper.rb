require 'plaything'
require 'spotify'
require_relative '../monkey_patches/plaything.rb'

class SpotifyWrapper

  SP_IMAGE_SIZE_NORMAL = 0

  attr_accessor :session
  attr_accessor :end_of_track

  def initialize config
    @config = config
    @plaything = Plaything.new
    @session = initialize_session config
  end

  def initialize_session config
    session_config = Spotify::SessionConfig.new({
      api_version: Spotify::API_VERSION.to_i,
      application_key: config.app_key,
      cache_location: '.spotify/',
      settings_location: '.spotify/',
      user_agent: 'spotify for ruby',
      callbacks: Spotify::SessionCallbacks.new(get_callbacks),
    })

    $logger.info "Creating session."
    session = nil
    FFI::MemoryPointer.new(Spotify::Session) do |ptr|
      Spotify.try(:session_create, session_config, ptr)
      session = Spotify::Session.new(ptr.read_pointer)
    end

    $logger.info "Created! Logging in."
    Spotify.session_login(session, config.username, config.password, false, nil)

    $logger.info "Log in requested. Waiting forever until logged in."
    poll(session) { Spotify.session_connectionstate(session) == :logged_in }

    $logger.info "Logged in as #{Spotify.session_user_name(session)}."
    session
  end

  def play!
    Spotify.try(:session_player_play, self.session, true)
  end

  def stop!
    Spotify.try(:session_player_play, self.session, false)
  end

  def skip!
    get_callbacks()[:end_of_track].call(@session)
  end

  def playing?
    @plaything.source.should_be_playing?
  end

  def get_tracks_for_playlist playlist
    spotify_playlist = get_playlist playlist.url
    num_tracks = Spotify.playlist_num_tracks(spotify_playlist)
    tracks = []
    (0..num_tracks-1).map do |index|
      track = Spotify.playlist_track spotify_playlist, index
      tracks << track
      track.free
    end
    tracks
  end

  def get_playlist playlist_url
    playlist_uri = convert_spotify_url_to_uri playlist_url

    link = Spotify.link_create_from_string playlist_uri
    playlist = Spotify.playlist_create @session, link

    poll { Spotify.playlist_is_loaded(playlist) }
    playlist
  end
  private :get_playlist

  def convert_spotify_url_to_uri url
    match_data = url.match /^.*user\/(.*)\/playlist\/(.*)$/
    user_id = match_data[1]
    playlist_id = match_data[2]
    uri_format = 'spotify:user:%s:playlist:%s'
    uri_format % [user_id, playlist_id]
  end

  def get_track_metadata track
    poll { Spotify.track_is_loaded track }
    track_name = Spotify.track_name track
    artists = (0..Spotify.track_num_artists(track) - 1).map do |i|
      artist = Spotify.track_artist track, i
      artist_name = Spotify.artist_name artist
      artist.free
      artist_name
    end.join(', ')
    album = Spotify.track_album track
    album_name = Spotify.album_name album
    album_cover_id = Spotify.album_cover(album, SP_IMAGE_SIZE_NORMAL)
    track.free
    album.free
    image_hex = if album_cover_id
                  album_cover_id.unpack('H40')[0]
                end
    {
       :name    => track_name,
       :artists => artists,
       :album   => album_name,
       :image   => image_hex
    }
  end

  def play_track(track)
    @end_of_track = false
    stop!
    Spotify.try(:session_player_load, @session, track)
    poll { Spotify.track_is_loaded(track) }
    play!
    poll { @end_of_track }
  rescue Spotify::Error => e
    $logger.error e.message
    if e.message =~ /^\[TRACK_NOT_PLAYABLE\]/
      @end_of_track = true
    else
      throw
    end
  end

  private
  # libspotify supports callbacks, but they are not useful for waiting on
  # operations (how they fire can be strange at times, and sometimes they
  # might not fire at all). As a result, polling is the way to go.
  def poll session=@session
    until yield
      FFI::MemoryPointer.new(:int) do |ptr|
        Spotify.session_process_events(session, ptr)
      end
      sleep(0.1)
    end
  end

  # Global callback procs.
  #
  # They are global variables to protect from ever being garbage collected.
  #
  # You must not allow the callbacks to ever be garbage collected, or libspotify
  # will hold information about callbacks that no longer exist, and crash upon
  # calling the first missing callback. This is *very* important!
  def get_callbacks
    $session_callbacks ||= {
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
        @end_of_track = false
        $logger.debug('session (player)') { 'start playback' }
        @plaything.play
      end,

      stop_playback: proc do |session|
        $logger.debug('session (player)') { 'stop playback' }
        @plaything.stop
      end,

      get_audio_buffer_stats: proc do |session, stats|
        stats[:samples] = @plaything.queue_size
        stats[:stutter] = @plaything.drops
      end,

      music_delivery: proc do |session, format, frames, num_frames|
        if num_frames == 0
          @plaything.stop
        else
          consumed_frames = @plaything.stream(format.to_h, frames, num_frames)
          consumed_frames
        end
      end,

      end_of_track: proc do |session|
        @end_of_track = true
        $logger.debug('session (player)') { 'end of track' }
        @plaything.stop
        Spotify.try(:session_player_unload, self.session)
      end,
    }
  end

end
