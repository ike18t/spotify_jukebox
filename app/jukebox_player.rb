require 'rest_client'

class JukeboxPlayer

  def initialize player_update_endpoint
    @player_update_endpoint = player_update_endpoint
    @historian = TrackHistorian.new
  end

  def start!
    current_user = nil
    loop do
      sleep 2
      enabled_users = UserService.get_users
      enabled_playlists = PlaylistService.get_enabled_playlists
      @historian.update_enabled_playlists_list enabled_playlists.map{ |p| p.name }
      if not enabled_playlists.empty?
        current_user = get_next_item enabled_users, current_user
        playlists = PlaylistService.get_enabled_playlists_for_user current_user.id
        next if playlists.empty?
        track = get_random_track_for_playlist playlists.sample
      end
      next if track.nil?
      notify track, current_user
      MusicService.play track
    end
  end

  private

  def notify track, user
    @historian.record track.artists, track.name
    $logger.info "Now playing #{track.name} by #{track.artists} on the album #{track.album.name}"
    begin
      RestClient.post @player_update_endpoint, { :player_info => WebHelper.track_info_to_json(track, user) }
    rescue Errno::ECONNREFUSED => ex
      $logger.info 'Jukebox server not available: ' + ex.message
    rescue Exception => ex
      $logger.info ex.message
    end
  end

  def get_random_track_for_playlist playlist
    tracks = PlaylistService.get_tracks_for_playlist playlist
    @historian.update_playlist_track_count playlist, tracks.count
    tracks.reject! do |track|
      @historian.played_recently?(track.artists, track.name)
    end
    tracks.sample
  end

  def get_next_item list, last
    last_index = list.index(last) || rand(list.count)
    list.rotate! last_index + 1
    list.first
  end

end
