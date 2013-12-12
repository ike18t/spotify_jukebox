class JukeboxPlayer
  require_relative 'cache_handler'

  attr_accessor :spotify_wrapper
  def initialize spotify_wrapper, queue, playlist_uri, track_historian
    @spotify_wrapper = spotify_wrapper
    @historian = track_historian
    @queue = queue
    @playlist_uri = playlist_uri
  end

  def start!
    playlist = @spotify_wrapper.get_playlist

    current_user = nil
    loop do
      enabled_users = CacheHandler.get_enabled_users
      @historian.update_enabled_users_list enabled_users
      if enabled_users.empty?
        rando = @spotify_wrapper.get_random_track playlist
        current_user = rando[:user]
        track = rando[:track]
      else
        current_user = get_next_user enabled_users, current_user
        track = get_random_track_for_user playlist, current_user
      end
      next if track.nil?
      notify_metadata(track, current_user)
      @spotify_wrapper.play_track(track)
    end
  end

  private

  def notify_metadata(track, who_added)
    metadata = @spotify_wrapper.get_track_metadata(track).merge({ :adder => who_added })
    @historian.record metadata[:artists], metadata[:name]
    $logger.info "Now playing #{metadata[:name]} by #{metadata[:artists]} on the album #{metadata[:album]}"
    @queue[:web].push(metadata)
  end

  def get_random_track_for_user playlist, user
    tracks = @spotify_wrapper.get_tracks_for_collaborator playlist, user
    @historian.update_user_track_count user, tracks.count
    tracks.reject! do |track|
      metadata = @spotify_wrapper.get_track_metadata track
      @historian.played_recently?(metadata[:artists], metadata[:name])
    end
    tracks.sample
  end

  def get_next_user enabled_users, last_user
    last_index = enabled_users.index(last_user) || rand(enabled_users.count)
    enabled_users.rotate! last_index + 1
    enabled_users.first
  end

end
