require_relative '../spec_helper'

describe PlaylistService do
  context 'create_playlist' do
    it 'should not add the playlist if it already exists' do
      existing = [Playlist.new(id: 123)]
      allow(PlaylistService).to receive(:get_playlists).and_return(existing)
      expect(PlaylistService).to receive(:save_playlists).never
      PlaylistService.create_playlist 123, 456, ''
    end

    it 'should add new playlist object to cache' do
      allow(UserService).to receive(:create_user)
      existing = []
      allow(PlaylistService).to receive(:get_playlists).and_return(existing)

      wrapper_double = double
      allow(wrapper_double).to receive(:get_playlist).and_return(double)
      expect(wrapper_double).to receive(:get_playlist_name).and_return('bah')

      expect(PlaylistService).to receive(:spotify_wrapper).twice.and_return(wrapper_double)
      expect(PlaylistService).to receive(:save_playlists)
      playlist = PlaylistService.create_playlist 123, 567, ''
      existing.include? playlist
    end

    it 'should set the playlists name from spotify' do
      allow(UserService).to receive(:create_user)
      allow(PlaylistService).to receive(:save_playlists)
      allow(PlaylistService).to receive(:get_playlists).and_return([])

      wrapper_double = double
      allow(wrapper_double).to receive(:get_playlist).and_return(double)
      expect(wrapper_double).to receive(:get_playlist_name).and_return('bah')

      expect(PlaylistService).to receive(:spotify_wrapper).twice.and_return(wrapper_double)
      playlist = PlaylistService.create_playlist 123, 567, ''
      expect(playlist.name).to eq('bah')
    end

    it 'should create_user if adding a playlist' do
      expect(PlaylistService).to receive(:save_playlists)
      expect(PlaylistService).to receive(:get_playlists).and_return([])

      wrapper_double = double
      expect(wrapper_double).to receive(:get_playlist).and_return(double)
      expect(wrapper_double).to receive(:get_playlist_name)

      expect(PlaylistService).to receive(:spotify_wrapper).twice.and_return(wrapper_double)
      expect(UserService).to receive(:create_user).once
      PlaylistService.create_playlist 123, 567, ''
    end

    it 'should default enabled to true' do
      expect(UserService).to receive(:create_user)
      existing = []
      expect(PlaylistService).to receive(:get_playlists).and_return(existing)

      wrapper_double = double
      expect(wrapper_double).to receive(:get_playlist).and_return(double)
      expect(wrapper_double).to receive(:get_playlist_name).and_return('bah')

      expect(PlaylistService).to receive(:spotify_wrapper).twice.and_return(wrapper_double)
      expect(PlaylistService).to receive(:save_playlists).once
      playlist = PlaylistService.create_playlist 123, 567, ''
      expect(playlist.enabled?).to be true
    end
  end

  context 'remove_playlist' do
    it 'should remove playlist form array and save' do
      playlists = [Playlist.new(id: 321, user_id: 321),
                   Playlist.new(id: 123, user_id: 321)]
      allow(PlaylistService).to receive(:get_playlists).and_return(playlists)
      expect(PlaylistService).to receive(:save_playlists).with([playlists[0]])
      PlaylistService.remove_playlist(123)
    end
  end

  context 'get_enabled_playlists_for_user' do
    it 'should only return playlists for the user_id' do
      user_playlists =     [Playlist.new(id: 321, user_id: 321),
                            Playlist.new(id: 123, user_id: 321)]
      not_user_playlists = [Playlist.new(id: 567, user_id: 123)]

      expect(PlaylistService).to receive(:get_playlists).and_return(user_playlists + not_user_playlists)
      expect(PlaylistService.get_playlists_for_user(321)).to eq(user_playlists)
    end
  end

  context 'get_enabled_playlists' do
    it 'should only return enabled playlists' do
      enabled  = [Playlist.new(enabled: true),
                  Playlist.new(enabled: true)]
      disabled = [Playlist.new(enabled: false)]

      expect(PlaylistService).to receive(:get_playlists).and_return(enabled + disabled)
      expect(PlaylistService.get_enabled_playlists).to eq(enabled)
    end
  end

  context 'get_enabled_playlists_for_user' do
    it 'should get playlists' do
      expect(PlaylistService).to receive(:get_playlists_for_user).with(1).and_return({})
      PlaylistService.get_enabled_playlists_for_user(1)
    end

    it 'should only return playlists that are enabled' do
      enabled =  [Playlist.new(id: 321, name: 'name321', uri: 'uri321', enabled: true),
                  Playlist.new(id: 567, name: 'name567', uri: 'uri567', enabled: true)]
      disabled = [Playlist.new(id: 123, name: 'name123', uri: 'uri123', enabled: false)]

      expect(PlaylistService).to receive(:get_playlists_for_user).with(1).and_return(enabled + disabled)
      expect(PlaylistService.get_enabled_playlists_for_user(1)).to eq(enabled)
    end
  end

  context 'get_playlists' do
    it 'should get playlists from cache' do
      expect(CacheService).to receive(:get_playlists)
      PlaylistService.get_playlists
    end
  end

  context 'save_playlists' do
    it 'should save_playlist playlists to cache' do
      expect(CacheService).to receive(:cache_playlists!).with({})
      PlaylistService.send(:save_playlists, {})
    end
  end

  context 'enable_playlist' do
    it 'should set enabled flag on playlist' do
      playlists = [Playlist.new(id: 123, name: 'name123', uri: 'uri123', enabled: false)]
      allow(PlaylistService).to receive(:get_playlists).and_return(playlists)
      expect(PlaylistService).to receive(:save_playlists)
      PlaylistService.enable_playlist 123
      expect(playlists[0].enabled?).to be true
    end

    it 'should not make save if playlist does not exist' do
      allow(PlaylistService).to receive(:get_playlists).and_return([])
      expect(PlaylistService).to receive(:save_playlists).never
      PlaylistService.enable_playlist 123
    end
  end

  context 'disable_playlist' do
    it 'should set enabled flag on playlist' do
      playlists = [Playlist.new(id: 123, name: 'name123', uri: 'uri123', enabled: true)]
      allow(PlaylistService).to receive(:get_playlists).and_return(playlists)
      allow(PlaylistService).to receive(:save_playlists)
      PlaylistService.disable_playlist 123
      expect(playlists[0].enabled?).to be false
    end

    it 'should not save changes if playlist does not exist' do
      allow(PlaylistService).to receive(:get_playlists).and_return([])
      expect(PlaylistService).to receive(:save_playlists).never
      PlaylistService.disable_playlist 123
    end
  end

  context 'get_tracks_for_playlist' do
    it 'should return all tracks for playlist' do
      wrapper_double = double
      playlist_double = double

      expect(wrapper_double).to receive(:get_playlist).with('uri').and_return(playlist_double)
      expect(wrapper_double).to receive(:get_track_count).with(playlist_double).and_return(2)
      expect(wrapper_double).to receive(:get_playlist_track).with(playlist_double, 0)
      expect(wrapper_double).to receive(:get_playlist_track).with(playlist_double, 1)
      expect(PlaylistService).to receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      expect(PlaylistService).to receive(:spotify_track_to_model).twice
      PlaylistService.get_tracks_for_playlist Playlist.new(uri: 'uri')
    end
  end

  context 'spotify_track_to_model' do
    it 'should return a new track loaded with values' do
      wrapper_double = double

      track = double(free: true)
      playlist = double(id: 123)
      album = double
      expect(wrapper_double).to receive(:get_track_name).with(track).and_return('track_name')
      expect(wrapper_double).to receive(:get_track_album).with(track).and_return(album)
      expect(PlaylistService).to receive(:spotify_album_to_model).with(album).and_return('track_album')
      expect(PlaylistService).to receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      expect(PlaylistService).to receive(:spotify_track_artists).with(track).and_return('track_artist')
      ret_track = PlaylistService.send(:spotify_track_to_model, playlist, track)
      expect(ret_track.name).to eq('track_name')
      expect(ret_track.playlist_id).to eq(123)
      expect(ret_track.artists).to eq('track_artist')
      expect(ret_track.album).to eq('track_album')
      expect(ret_track.spotify_track).to eq(track)
    end
  end

  context 'spotify_track_artists' do
    it 'should return an array of artists' do
      wrapper_double = double
      track = double
      artist1 = double
      artist2 = double
      expect(wrapper_double).to receive(:get_artist_count).with(track).and_return(2)
      expect(wrapper_double).to receive(:get_track_artist).with(track, 0).and_return(artist1)
      expect(wrapper_double).to receive(:get_track_artist).with(track, 1).and_return(artist2)
      expect(wrapper_double).to receive(:get_artist_name).with(artist1).and_return(:artist1)
      expect(wrapper_double).to receive(:get_artist_name).with(artist2).and_return(:artist2)
      expect(PlaylistService).to receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      expect(PlaylistService.send(:spotify_track_artists, track)).to eq([:artist1, :artist2])
    end
  end

  context 'spotify_album_to_model' do
    it 'should return a populated album object' do
      album_double = double(free: true)
      cover_double = double(unpack: [:hex])
      wrapper_double = double
      expect(wrapper_double).to receive(:get_album_name).with(album_double).and_return(:album_name)
      expect(wrapper_double).to receive(:get_album_cover).with(album_double, PlaylistService::SP_IMAGE_SIZE_NORMAL).and_return(cover_double)
      expect(PlaylistService).to receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      album = PlaylistService.send(:spotify_album_to_model, album_double)
      expect(album.name).to eq(:album_name)
      expect(album.art_hex).to eq(:hex)
    end
  end
end
