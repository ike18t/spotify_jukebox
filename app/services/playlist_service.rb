class PlaylistService < ServiceBase
  SP_IMAGE_SIZE_NORMAL = 0

  class << self
    def create_playlist id, user_id, uri
      playlists = get_playlists
      if playlists.select{ |p| p.id == id }.empty?
        playlist = spotify_wrapper.get_playlist uri
        playlist_name = spotify_wrapper.get_playlist_name playlist
        playlist = Playlist.new :id => id, :name => playlist_name, :uri => uri, :user_id => user_id
        playlists << playlist
        save_playlists playlists
        UserService.create_user user_id
      end
      playlist
    end

    def remove_playlist id
      playlists = get_playlists
      playlists.reject!{ |p| p.id == id }
      save_playlists playlists
    end

    def get_playlists_for_user user_id
      get_playlists.select{ |p| p.user_id == user_id }
    end

    def get_enabled_playlists_for_user user_id
      playlists = get_playlists_for_user user_id
      playlists.select(&:enabled?)
    end

    def enable_playlist id
      playlists = get_playlists
      playlist_index = playlists.index { |playlist| playlist.id == id }
      if not playlist_index.nil?
        playlists[playlist_index].enabled = true
        save_playlists playlists
      end
    end

    def disable_playlist id
      playlists = get_playlists
      playlist_index = playlists.index { |playlist| playlist.id == id }
      if not playlist_index.nil?
        playlists[playlist_index].enabled = false
        save_playlists playlists
      end
    end

    def get_tracks_for_playlist playlist
      spotify_playlist = spotify_wrapper.get_playlist playlist.uri
      num_tracks = spotify_wrapper.get_track_count(spotify_playlist)
      (0..num_tracks-1).map do |index|
        track = spotify_wrapper.get_playlist_track spotify_playlist, index
        spotify_track_to_model(playlist, track)
      end
    end

    def get_playlists
      CacheService.get_playlists
    end

    private
    def save_playlists playlists
      CacheService.cache_playlists! playlists
    end

    def spotify_track_to_model playlist, spotify_track
      track_name = spotify_wrapper.get_track_name spotify_track
      album = spotify_wrapper.get_track_album spotify_track
      album = spotify_album_to_model album
      artists = spotify_track_artists spotify_track
      spotify_track.free
      Track.new :name => track_name, :playlist_id => playlist.id, :artists => artists, :album => album, :spotify_track => spotify_track
    end

    def spotify_track_artists spotify_track
      (0..spotify_wrapper.get_artist_count(spotify_track) - 1).map do |i|
        artist = spotify_wrapper.get_track_artist spotify_track, i
        spotify_wrapper.get_artist_name(artist)
      end
    end

    def spotify_album_to_model album
      album_name = spotify_wrapper.get_album_name album
      album_cover_id = spotify_wrapper.get_album_cover(album, SP_IMAGE_SIZE_NORMAL)
      image_hex = album_cover_id.unpack('H40')[0] if album_cover_id
      album.free
      Album.new :name => album_name, :art_hex => image_hex
    end
  end
end
