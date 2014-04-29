require_relative 'spec_helper'

describe JukeboxPlayer do
  context 'get_tracks_for_playlist' do
    it 'should not return tracks that have been played recently' do
      not_expected_1 = { :artist => 'artist_1', :name => 'track_1' }
      not_expected_2 = { :artist => 'artist_2', :name => 'track_2' }
      not_expected_3 = { :artist => 'artist_3', :name => 'track_3' }
      tracks = [ not_expected_1, not_expected_2, not_expected_3 ]
      spotify_wrapper = double(SpotifyWrapper)
      spotify_wrapper.stubs(:get_tracks_for_playlist).returns(tracks)
      tracks.each do |track|
        spotify_wrapper.stubs(:get_track_metadata).with(track).returns(track)
      end

      historian = TrackHistorian.new
      historian.stubs(:played_recently?).returns(true)
      jukebox_player = JukeboxPlayer.new spotify_wrapper, nil, historian
      jukebox_player.send(:get_random_track_for_playlist, Playlist.new).should eql(nil)
    end

    it 'should return a track that has not been played recently' do
      not_expected_1 = { :artists => 'artist_1', :name => 'track_1' }
      expected = { :artists => 'artist_2', :name => 'track_2' }
      not_expected_2 = { :artists => 'artist_3', :name => 'track_3' }
      tracks = [ not_expected_1, expected, not_expected_2 ]
      spotify_wrapper = double(SpotifyWrapper)
      expect(spotify_wrapper).to receive(:get_tracks_for_playlist).with('playlist').and_return(tracks)
      historian = double(TrackHistorian)
      expect(historian).to receive(:update_playlist_track_count).with('playlist', 3)
      tracks.each do |track|
        expect(spotify_wrapper).to receive(:get_track_metadata).with(track).and_return(track)
        expect(historian).to receive(:played_recently?).with(track[:artists], track[:name]).and_return(expected != track)
      end

      jukebox_player = JukeboxPlayer.new spotify_wrapper, nil, historian
      jukebox_player.send(:get_random_track_for_playlist, 'playlist').should eql(expected)
    end
  end
end
