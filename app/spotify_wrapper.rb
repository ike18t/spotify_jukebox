class SpotifyWrapper
  require 'plaything'
  require 'spotify'
  require_relative 'frame_reader'

  attr_accessor :session
  attr_accessor :end_of_track

  def initialize config, queue
    @config = config
    @queue = queue
    @plaything = Plaything.new
    @session = initialize_session config
    @end_of_track = false
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
        $logger.debug('session (player)') { "queue size [#{stats[:samples]}, #{stats[:stutter]}]" }
      end,

      music_delivery: proc do |session, format, frames, num_frames|
        if num_frames == 0
          @plaything.stop
          $logger.debug('session (player)') { "music delivery audio discontuity" }
        else
          frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
          consumed_frames = @plaything.stream(frames, format.to_h)
          $logger.debug('session (player)') { "#{format.to_h}" }
          $logger.debug('session (player)') { "music delivery #{consumed_frames} of #{num_frames}" }
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

  def initialize_session config
    session_config = Spotify::SessionConfig.new({
      api_version: Spotify::API_VERSION.to_i,
      application_key: config.app_key,
      cache_location: '.spotify/',
      settings_location: '.spotify/',
      tracefile: 'spotify_tracefile.txt',
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

  def play
    Spotify.try(:session_player_play, self.session, true)
  end

  def pause
    Spotify.try(:session_player_play, self.session, false)
  end

  def playing?
    @plaything.source.should_be_playing?
  end

  def get_collaborator_list
    @collaborator_list ||= begin
      link = Spotify.link_create_from_string @config.playlist_uri
      playlist = Spotify.playlist_create @session, link
      poll { Spotify.playlist_is_loaded(playlist) }
      (0..Spotify.playlist_num_tracks(playlist)-1).map{|index|
        creator = Spotify.playlist_track_creator(playlist, index)
        user = Spotify.user_canonical_name creator
        creator.free
        user
      }.uniq.sort
    end
    @collaborator_list.clone
  end

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
end
