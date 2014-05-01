class PlaylistService < ServiceBase
  class << self
    def create_playlist uri, spotify_id, user_id
      playlist = spotify_wrapper.get_playlist uri
      playlist_name = spotify_wrapper.get_playlist_name playlist
      playlist = Playlist.new :id => spotify_id, :name => playlist_name, :uri => uri, :user_id => user_id
      playlists = CacheService.get_playlists
      playlists << playlist
      CacheService.cache_playlists! playlists
      UserService.create_user user_id
      playlist
    end

    def remove_playlist id
      playlists = CacheService.get_playlists
      playlists.reject!{ |p| p.id == id }
      CacheService.cache_playlists! playlists
    end

    def get_playlists_for_user user_id
      get_playlists.select{ |p| p.user_id == user_id }
    end

    def get_playlists
      CacheService.get_playlists
    end

    def enable_playlist id
      playlists = CacheService.get_playlists
      playlist_index = playlists.index { |playlist| playlist.id == id }
      playlists[playlist_index].enabled = true
      CacheService.cache_playlists! playlists
    end

    def disable_playlist id
      playlists = CacheService.get_playlists
      playlist_index = playlists.index { |playlist| playlist.id == id }
      playlists[playlist_index].enabled = false
      CacheService.cache_playlists! playlists
    end

    def get_tracks_for_playlist playlist
      spotify_playlist = spotify_wrapper.get_playlist playlist.uri
      num_tracks = spotify_wrapper.get_track_count(spotify_playlist)
      tracks = []
      (0..num_tracks-1).map do |index|
        track = spotify_wrapper.get_playlist_track spotify_playlist, index
        tracks << spotify_track_to_model(playlist, track)
      end
      tracks
    end

    private

    def spotify_track_to_model playlist, spotify_track
      track_name = spotify_wrapper.get_track_name spotify_track
      artists = []
      (0..spotify_wrapper.get_artist_count(spotify_track) - 1).each do |i|
        artist = spotify_wrapper.get_track_artist spotify_track, i
        artists << spotify_wrapper.get_artist_name(artist)
      end
      album = spotify_wrapper.get_track_album spotify_track
      spotify_track.free
      album = spotify_album_to_model album
      Track.new :name => track_name, :playlist_id => playlist.id, :artists => artists, :album => album, :spotify_track => spotify_track
    end

    SP_IMAGE_SIZE_NORMAL = 0

    def spotify_album_to_model album
      album_name = spotify_wrapper.get_album_name album
      album_cover_id = spotify_wrapper.get_album_cover(album, SP_IMAGE_SIZE_NORMAL)
      image_hex = album_cover_id.unpack('H40')[0] if album_cover_id
      album.free
      album = Album.new :name => album_name, :art_hex => image_hex
    end
  end
end
