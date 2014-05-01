class JukeboxPlayer

  def initialize message_queue, track_historian
    @historian = track_historian
    @message_queue = message_queue
  end

  def start!
    current_user = nil
    loop do
      sleep 2
      enabled_users = UserService.get_enabled_users
      #@historian.update_enabled_playlists_list enabled_playlists.map{|p| p.name}
      if not enabled_users.empty?
        current_user = get_next_item enabled_users, current_user
        playlists = PlaylistService.get_playlists_for_user current_user.id
        track = get_random_track_for_playlist playlists.sample
      end
      next if track.nil?
      notify track
      MusicService.play track
    end
  end

  private

  def notify track
    #@historian.record metadata[:artists], metadata[:name]
    $logger.info "Now playing #{track.name} by #{track.artists} on the album #{track.album.name}"
    @message_queue.push track
  end

  def get_random_track_for_playlist playlist
    tracks = PlaylistService.get_tracks_for_playlist playlist
    #@historian.update_playlist_track_count playlist, tracks.count
    #tracks.reject! do |track|
    #  @historian.played_recently?(track.artists, track.name)
    #end
    tracks.sample
  end

  def get_next_item list, last
    last_index = list.index(last) || rand(list.count)
    list.rotate! last_index + 1
    list.first
  end

end
