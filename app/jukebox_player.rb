class JukeboxPlayer
  require_relative 'cache_handler'

  SP_IMAGE_SIZE_NORMAL = 0
  attr_accessor :session_wrapper
  def initialize session_wrapper, queue, playlist_uri, track_historian
    @session_wrapper = session_wrapper
    @historian = track_historian
    @queue = queue
    @playlist_uri = playlist_uri
  end

  def start!
    playlist = get_playlist

    loop do
      enabled_users = CacheHandler.get_enabled_users
      @historian.update_enabled_users_list enabled_users
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
      @session_wrapper.poll { $end_of_track }
    end
  end

  private
  def play_track(track)
    @session_wrapper.poll { Spotify.track_is_loaded(track) }
    Spotify.try(:session_player_play, @session_wrapper.session, false)
    Spotify.try(:session_player_load, @session_wrapper.session, track)
    Spotify.try(:session_player_play, @session_wrapper.session, true)
    $end_of_track = false
  rescue Spotify::Error => e
    logger.error e.message
    if e.message =~ /^\[TRACK_NOT_PLAYABLE\]/
      $end_of_track = true
    else
      throw
    end
  end

  def log_metadata(track, who_added)
    track_name = Spotify.track_name track
    artists = (0..Spotify.track_num_artists(track) - 1).map do |i|
      artist = Spotify.track_artist track, i
      @session_wrapper.poll { Spotify.artist_is_loaded(artist) }
      Spotify.artist_name artist
    end
    album = Spotify.track_album(track)
    @session_wrapper.poll { Spotify.album_is_loaded(album) }
    album_name = Spotify.album_name album
    album_cover_id = Spotify.album_cover(Spotify.track_album(track), SP_IMAGE_SIZE_NORMAL)
    image_hex = if album_cover_id
                  album_cover_id.unpack('H40')[0]
                end
    @historian.record artists.first, track_name
    $logger.info "Now playing #{track_name} by #{artists.join(", ")} on the album #{album_name}"
    @queue[:web].push({
                       :track_name => track_name,
                       :artists    => artists.join(", "),
                       :album_name => album_name,
                       :image      => image_hex,
                       :adder      => who_added
                    })
  end

  def get_playlist
    link = Spotify.link_create_from_string @playlist_uri
    playlist = Spotify.playlist_create @session_wrapper.session, link

    @session_wrapper.poll { Spotify.playlist_is_loaded(playlist) }
    playlist
  end

  def get_tracks_for_user playlist, user
    tracks = []
    num_tracks = Spotify.playlist_num_tracks(playlist)
    (0..num_tracks-1).each do |index|
      track = Spotify.playlist_track(playlist, index)
      @session_wrapper.poll { Spotify.track_is_loaded(track) }
      creator = Spotify.playlist_track_creator(playlist, index)
      @session_wrapper.poll { Spotify.user_is_loaded(creator) }
      tracks << track if Spotify.user_canonical_name(creator) == user
    end
    @historian.update_user_track_count user, tracks.count
    tracks.reject do |track|
      track_name = Spotify.track_name track
      artist = Spotify.track_artist track, 0
      @session_wrapper.poll { Spotify.artist_is_loaded(artist) }
      artist_name = Spotify.artist_name artist
      @historian.played_recently?(artist_name, track_name)
    end
  end

  def get_random_track_for_user playlist, user
    tracks = get_tracks_for_user playlist, user
    tracks.sample
  end

  def get_random_track playlist
    random_track_index = rand(Spotify.playlist_num_tracks(playlist))

    creator = Spotify.playlist_track_creator(playlist, random_track_index)
    @session_wrapper.poll { Spotify.user_is_loaded(creator) }
    added_by = Spotify.user_canonical_name creator
    track = Spotify.playlist_track(playlist, random_track_index)
    @session_wrapper.poll { Spotify.track_is_loaded(track) }
    { :user => added_by, :track => track }
  end

  def get_next_user enabled_users, last_user
    last_index = enabled_users.index(last_user) || rand(enabled_users.count)
    enabled_users.rotate! last_index + 1
    enabled_users.first
  end

end
