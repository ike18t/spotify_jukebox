require 'rest_client'

class JukeboxPlayer
  def initialize(player_update_endpoint, player_status_update_endpoint)
    @player_update_endpoint = player_update_endpoint
    @player_status_update_endpoint = player_status_update_endpoint
    @historian = TrackHistorian.new
    @current_user = nil
    start_signal_watcher
  end

  def set_playing(val)
    notify_status val
    @playing = val
  end

  def playing
    @playing
  end

  def start!
    play_a_song
    set_playing(SpotifyService.playing?)
    loop do
      if playing && SpotifyService.end_of_song?
        play_a_song
      elsif playing && !SpotifyService.playing?
        SpotifyService.pause(false)
      end
      sleep 2
    end
  end

  private

  def start_signal_watcher
    File.write('tmp/pid', Process.pid)

    Signal.trap(:USR1) do
      puts 'SKIP'
      play_a_song
      set_playing true
    end

    Signal.trap(:CONT) do
      puts 'PLAY'
      SpotifyService.pause(false)
      set_playing true
    end

    Signal.trap(:USR2) do
      puts 'PAUSE'
      SpotifyService.pause
      set_playing false
    end
  end

  def play_a_song
    enabled_users = UserService.get_enabled_users
    enabled_playlists = PlaylistService.get_enabled_playlists
    @historian.update_enabled_playlists_list enabled_playlists.map(&:name)
    track = nil
    unless enabled_users.empty?
      original_user = @current_user
      loop do
        @current_user = SpinDoctor.get_next_item enabled_users, @current_user
        playlists = PlaylistService.get_enabled_playlists_for_user @current_user.id
        return if @current_user == original_user && playlists.empty?
        next if playlists.empty?
        track = get_random_track_for_playlist playlists.sample
        break
      end
    end
    @historian.pop && return if track.nil?
    notify track, @current_user
    SpotifyService.play track
  end

  def get_random_track_for_playlist(playlist)
    config = ConfigService.get
    RSpotify::authenticate(config.client_id, config.client_secret)
    spotify_playlist = RSpotify::Playlist.find(playlist.user_id, playlist.id)
    num_tracks = spotify_playlist.total
    spotify_playlist.tracks(limit: 10, offset: rand(num_tracks)).each do |track|
      if !@historian.played_recently?(track.artists.first.name, track.name)
        return track
      end
    end
    nil
  end

  def notify(track, user)
    @historian.record track.artists.first.name, track.name
    $logger.info "Now playing #{track.name} by #{track.artists.first.name} on the album #{track.album.name}"
    begin
      RestClient.post @player_update_endpoint, now_playing: WebHelper.track_info_to_json(track, user)
    rescue Errno::ECONNREFUSED => ex
      $logger.info 'Jukebox server not available: ' + ex.message
    rescue Exception => ex
      $logger.info ex.message
    end
  end

  def notify_status(playing = false)
    begin
      RestClient.post @player_status_update_endpoint, status: { playing: playing }.to_json
    rescue Errno::ECONNREFUSED => ex
      $logger.info 'Jukebox server not available: ' + ex.message
    rescue Exception => ex
      $logger.info ex.message
    end
  end
end
