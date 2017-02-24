class PlaylistService
  class << self
    def create_playlist(id, user_id, uri)
      playlists = get_playlists
      if playlists.select { |p| p.id == id }.empty?
        playlist_name = get_name(user_id, id)
        playlist = Playlist.new id: id, name: playlist_name, uri: uri, user_id: user_id, enabled: true
        playlists << playlist
        save_playlists playlists
        UserService.create_user user_id
      end
      playlist
    end

    def remove_playlist(id)
      playlists = get_playlists
      playlists.reject! { |p| p.id == id }
      save_playlists playlists
    end

    def get_playlist(playlist_id)
      get_playlists.find { |pl| pl.id == playlist_id }
    end

    def get_playlists_for_user(user_id)
      get_playlists.select { |p| p.user_id == user_id }
    end

    def get_enabled_playlists_for_user(user_id)
      playlists = get_playlists_for_user user_id
      playlists.select(&:enabled?)
    end

    def get_enabled_playlists
      playlists = get_playlists
      playlists.select(&:enabled?)
    end

    def enable_playlist(id)
      set_enabled id, true
    end

    def disable_playlist(id)
      set_enabled id, false
    end

    def get_playlists
      CacheService.get_playlists
    end

    private

    def get_name user_id, playlist_id
      spotify_playlist = RSpotify::Playlist.find(user_id, playlist_id)
      spotify_playlist.name
    end

    def save_playlists(playlists)
      CacheService.cache_playlists! playlists
    end

    def set_enabled(playlist_id, enabled)
      playlists = get_playlists
      playlist_index = playlists.index { |playlist| playlist.id == playlist_id }
      unless playlist_index.nil?
        playlists[playlist_index].enabled = enabled
        save_playlists playlists
      end
    end
  end
end
