require_relative '../spec_helper'

describe PlaylistService do
  context 'create_playlist' do
    it 'should not add the playlist if it already exists' do
      existing = [ Playlist.new(:id => 123) ]
      PlaylistService.stubs(:get_playlists).returns(existing);
      PlaylistService.should_not_receive(:save_playlists)
      PlaylistService.create_playlist 123, 456, ''
    end

    it 'should add new playlist object to cache' do
      UserService.stubs(:create_user)
      existing = []
      PlaylistService.stubs(:get_playlists).returns(existing)

      wrapper_double = double
      wrapper_double.stubs(:get_playlist).returns(double)
      expect(wrapper_double).to receive(:get_playlist_name).and_return('bah')

      PlaylistService.should_receive(:spotify_wrapper).twice.and_return(wrapper_double)
      PlaylistService.expects(:save_playlists)
      playlist = PlaylistService.create_playlist 123, 567, ''
      existing.include? playlist
    end

    it 'should set the playlists name from spotify' do
      UserService.stubs(:create_user)
      PlaylistService.stubs(:save_playlists)
      PlaylistService.stubs(:get_playlists).returns([])

      wrapper_double = double
      wrapper_double.stubs(:get_playlist).returns(double)
      expect(wrapper_double).to receive(:get_playlist_name).and_return('bah')

      PlaylistService.should_receive(:spotify_wrapper).twice.and_return(wrapper_double)
      playlist = PlaylistService.create_playlist 123, 567, ''
      playlist.name.should eq('bah')
    end

    it 'should create_user if adding a playlist' do
      PlaylistService.stubs(:save_playlists)
      PlaylistService.stubs(:get_playlists).returns([])

      wrapper_double = double
      wrapper_double.stubs(:get_playlist).returns(double)
      wrapper_double.stubs(:get_playlist_name)

      PlaylistService.should_receive(:spotify_wrapper).twice.and_return(wrapper_double)
      UserService.expects(:create_user).once
      PlaylistService.create_playlist 123, 567, ''
    end

    it 'should default enabled to true' do
      UserService.stubs(:create_user)
      existing = []
      PlaylistService.stubs(:get_playlists).returns(existing)

      wrapper_double = double
      wrapper_double.stubs(:get_playlist).returns(double)
      expect(wrapper_double).to receive(:get_playlist_name).and_return('bah')

      PlaylistService.should_receive(:spotify_wrapper).twice.and_return(wrapper_double)
      PlaylistService.expects(:save_playlists)
      playlist = PlaylistService.create_playlist 123, 567, ''
      playlist.enabled?.should be_true
    end
  end

  context 'remove_playlist' do
    it 'should remove playlist form array and save' do
      playlists =  [ Playlist.new(:id => 321, :user_id => 321),
                     Playlist.new(:id => 123, :user_id => 321) ]
      PlaylistService.stubs(:get_playlists).returns(playlists)
      PlaylistService.expects(:save_playlists).with([playlists[0]])
      PlaylistService.remove_playlist(123)
    end
  end

  context 'get_enabled_playlists_for_user' do
    it 'should only return playlists for the user_id' do
      user_playlists =     [ Playlist.new(:id => 321, :user_id => 321),
                             Playlist.new(:id => 123, :user_id => 321) ]
      not_user_playlists = [ Playlist.new(:id => 567, :user_id => 123) ]

      PlaylistService.should_receive(:get_playlists).and_return(user_playlists + not_user_playlists)
      PlaylistService.get_playlists_for_user(321).should eq(user_playlists)
    end
  end

  context 'get_enabled_playlists_for_user' do
    it 'should get playlists' do
      PlaylistService.should_receive(:get_playlists_for_user).with(1).and_return({})
      PlaylistService.get_enabled_playlists_for_user(1)
    end

    it 'should only return playlists that are enabled' do
      enabled =  [ Playlist.new(:id => 321, :name => 'name321', :uri => 'uri321', :enabled => true),
                   Playlist.new(:id => 567, :name => 'name567', :uri => 'uri567', :enabled => true) ]
      disabled = [ Playlist.new(:id => 123, :name => 'name123', :uri => 'uri123', :enabled => false) ]

      PlaylistService.should_receive(:get_playlists_for_user).with(1).and_return(enabled + disabled)
      PlaylistService.get_enabled_playlists_for_user(1).should eq(enabled)
    end
  end

  context 'get_playlists' do
    it 'should get playlists from cache' do
      PlaylistService.unstub(:get_playlists)
      CacheService.should_receive(:get_playlists)
      PlaylistService.get_playlists
    end
  end

  context 'save_playlists' do
    it 'should save_playlist playlists to cache' do
      PlaylistService.unstub(:save_playlists)
      CacheService.should_receive(:cache_playlists!).with({})
      PlaylistService.send(:save_playlists, {})
    end
  end

  context 'enable_playlist' do
    it 'should set enabled flag on playlist' do
      playlists = [ Playlist.new(:id => 123, :name => 'name123', :uri => 'uri123', :enabled => false) ]
      PlaylistService.stubs(:get_playlists).returns playlists
      PlaylistService.stubs :save_playlists
      PlaylistService.enable_playlist 123
      playlists[0].enabled?.should eq(true)
    end

    it 'should not make save if playlist does not exist' do
      PlaylistService.stubs(:get_playlists).returns []
      PlaylistService.should_not_receive :save_playlists
      PlaylistService.enable_playlist 123
    end
  end

  context 'disable_playlist' do
    it 'should set enabled flag on playlist' do
      playlists = [ Playlist.new(:id => 123, :name => 'name123', :uri => 'uri123', :enabled => true) ]
      PlaylistService.stubs(:get_playlists).returns playlists
      PlaylistService.stubs :save_playlists
      PlaylistService.disable_playlist 123
      playlists[0].enabled?.should eq(false)
    end

    it 'should not save changes if playlist does not exist' do
      PlaylistService.stubs(:get_playlists).returns []
      PlaylistService.should_not_receive :save_playlists
      PlaylistService.disable_playlist 123
    end
  end

  context 'get_tracks_for_playlist' do
    it 'should return all tracks for playlist' do
      wrapper_double = double
      playlist_double = double

      wrapper_double.should_receive(:get_playlist).with('uri').and_return(playlist_double)
      wrapper_double.should_receive(:get_track_count).with(playlist_double).and_return(2)
      wrapper_double.should_receive(:get_playlist_track).with(playlist_double, 0)
      wrapper_double.should_receive(:get_playlist_track).with(playlist_double, 1)
      PlaylistService.should_receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      PlaylistService.should_receive(:spotify_track_to_model).twice
      PlaylistService.get_tracks_for_playlist Playlist.new(:uri => 'uri')
    end
  end

  context 'spotify_track_to_model' do
    it 'should return a new track loaded with values' do
      wrapper_double = double

      track = double(:free => true)
      playlist = double(:id => 123)
      album = double
      wrapper_double.should_receive(:get_track_name).with(track).and_return('track_name')
      wrapper_double.should_receive(:get_track_album).with(track).and_return(album)
      PlaylistService.should_receive(:spotify_album_to_model).with(album).and_return('track_album')
      PlaylistService.should_receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      PlaylistService.should_receive(:spotify_track_artists).with(track).and_return('track_artist')
      ret_track = PlaylistService.send(:spotify_track_to_model, playlist, track)
      ret_track.name.should eq('track_name')
      ret_track.playlist_id.should eq(123)
      ret_track.artists.should eq('track_artist')
      ret_track.album.should eq('track_album')
      ret_track.spotify_track.should eq(track)
    end
  end

  context 'spotify_track_artists' do
    it 'should return an array of artists' do
      wrapper_double = double
      track = double
      artist1 = double
      artist2 = double
      wrapper_double.should_receive(:get_artist_count).with(track).and_return(2)
      wrapper_double.should_receive(:get_track_artist).with(track, 0).and_return(artist1)
      wrapper_double.should_receive(:get_track_artist).with(track, 1).and_return(artist2)
      wrapper_double.should_receive(:get_artist_name).with(artist1).and_return(:artist1)
      wrapper_double.should_receive(:get_artist_name).with(artist2).and_return(:artist2)
      PlaylistService.should_receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      PlaylistService.send(:spotify_track_artists, track).should eq([:artist1, :artist2])
    end
  end

  context 'spotify_album_to_model' do
    it 'should return a populated album object' do
      album_double = double(:free => true)
      cover_double = double(:unpack => [:hex])
      wrapper_double = double
      wrapper_double.should_receive(:get_album_name).with(album_double).and_return(:album_name)
      wrapper_double.should_receive(:get_album_cover).with(album_double, PlaylistService::SP_IMAGE_SIZE_NORMAL).and_return(cover_double)
      PlaylistService.should_receive(:spotify_wrapper).at_least(1).times.and_return(wrapper_double)
      album = PlaylistService.send(:spotify_album_to_model, album_double)
      album.name.should eq(:album_name)
      album.art_hex.should eq(:hex)
    end
  end
end
