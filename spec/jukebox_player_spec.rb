require 'spec_helper'

describe JukeboxPlayer do
  context 'get_tracks_for_user' do
    before do
      Spotify.stubs(:playlist_track_creator)
      Spotify.stubs(:track_is_loaded).returns('true')
      Spotify.stubs(:user_is_loaded).returns('true')
      Spotify.stubs(:track_name).returns('track_name')
      Spotify.stubs(:track_artist).returns('artist')
      Spotify.stubs(:user_canonical_name).returns('user')
      @historian = TrackHistorian.new
    end

    it 'should not return tracks that have been played recently' do
      Spotify.stubs(:playlist_track)
      Spotify.stubs(:playlist_num_tracks).returns(2)
      Spotify.stubs(:artist_name).returns('artist_name')
      @historian.stubs(:played_recently?).returns(true)
      session_wrapper = double(poll: true)
      jukebox_player = JukeboxPlayer.new session_wrapper, @historian
      jukebox_player.send(:get_tracks_for_user, 'playlist', 'user').should eql([])
    end

    it 'should return tracks that have not been played recently' do
      Spotify.stubs(:playlist_num_tracks).returns(3)
      Spotify.stubs(:artist_name).returns('a')
      Spotify.stubs(:playlist_track).returns('a', 'b', 'c')
      Spotify.stubs(:track_name).returns('a', 'b', 'c')
      @historian.stubs(:played_recently?).returns(false)
      @historian.stubs(:played_recently?).with('a', 'b').returns(true)
      session_wrapper = double(poll: true)
      jukebox_player = JukeboxPlayer.new session_wrapper, @historian
      jukebox_player.send(:get_tracks_for_user, 'playlist', 'user').should eql(['a', 'c'])
    end
  end
end
