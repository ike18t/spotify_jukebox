class SessionWrapper
  require_relative 'frame_reader'
  require_relative 'common'
  require 'plaything'

  attr_accessor :session

  def initialize
    @plaything = Plaything.new
    @session = initialize_session
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
        $end_of_track = true
        $logger.debug('session (player)') { 'end of track' }
        @plaything.stop
      end,
    }
  end

  def initialize_session
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
      callbacks: Spotify::SessionCallbacks.new(get_callbacks),
    })

    $logger.info "Creating session."
    session = nil
    FFI::MemoryPointer.new(Spotify::Session) do |ptr|
      Spotify.try(:session_create, config, ptr)
      session = Spotify::Session.new(ptr.read_pointer)
    end

    $logger.info "Created! Logging in."
    Spotify.session_login(session, $username, $password, false, nil)

    $logger.info "Log in requested. Waiting forever until logged in."
    poll(session) { Spotify.session_connectionstate(session) == :logged_in }

    $logger.info "Logged in as #{Spotify.session_user_name(session)}."
    session
  end
end
