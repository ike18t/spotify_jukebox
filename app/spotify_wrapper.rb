require 'plaything'
require 'spotify'
require_relative '../monkey_patches/plaything.rb'

class SpotifyWrapper

  DELEGATE_GETTERS = [ :album_cover,
                       :album_name,
                       :artist_name,
                       :track_name,
                       :playlist_name,
                       :playlist_track,
                       :track_album,
                       :track_artist ]

  DELEGATE_GETTERS.each do |method_name|
    define_method('get_' + method_name.to_s) do |*args|
      Spotify.send method_name, *args
    end
  end

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
    Spotify.try(:session_player_play, @session, true)
  end

  def stop!
    Spotify.try(:session_player_play, @session, false)
  end

  def skip!
    get_callbacks()[:end_of_track].call(@session)
  end

  def playing?
    @plaything.source.should_be_playing?
  end

  def get_track_count spotify_playlist
    Spotify.playlist_num_tracks spotify_playlist
  end

  def get_artist_count spotify_track
    Spotify.track_num_artists spotify_track
  end

  def get_track_album spotify_track
    album = Spotify.track_album spotify_track
    poll { Spotify.album_is_loaded(album) }
    album
  end

  def get_playlist playlist_uri
    link = Spotify.link_create_from_string playlist_uri
    playlist = Spotify.playlist_create @session, link

    poll { Spotify.playlist_is_loaded(playlist) }
    playlist
  end

  def play_track spotify_track
    @end_of_track = false
    stop!
    Spotify.try(:session_player_load, @session, spotify_track)
    poll { Spotify.track_is_loaded(spotify_track) }
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
        Spotify.try(:session_player_unload, @session)
      end,
    }
  end

end
