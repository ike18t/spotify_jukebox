require 'spec_helper'

describe JukeboxPlayer do
  context 'get_tracks_for_user' do
    before do
      Spotify.stubs(:playlist_track)
      Spotify.stubs(:playlist_track_creator)
      Spotify.stubs(:user_canonical_name).returns('user')
      @historian = TrackHistorian.new
    end

    it 'should not return tracks that have been played recently' do
      Spotify.stubs(:playlist_num_tracks).returns(2)
      @historian.stubs(:played_recently?).returns(true)
      jukebox_player = JukeboxPlayer.new nil, @historian
      jukebox_player.send(:get_tracks_for_user, 'playlist', 'user').should eql([])
    end

    it 'should return tracks that have not been played recently' do
      Spotify.stubs(:playlist_num_tracks).returns(3)
      Spotify.stubs(:playlist_track).returns('a', 'b', 'c')
      @historian.stubs(:played_recently?).returns(false)
      @historian.stubs(:played_recently?).with('b').returns(true)
      jukebox_player = JukeboxPlayer.new nil, @historian
      jukebox_player.send(:get_tracks_for_user, 'playlist', 'user').should eql(['a', 'c'])
    end
  end
end
