require_relative 'spec_helper'

describe JukeboxWeb do
  def app
    JukeboxWeb
  end

  describe 'playlists' do
    context 'post' do
      it 'should create a playlist out of the playlist_url posted' do
        user_id = '1295855412'
        playlist_id = '7Co7hqxAQFSAV7bMtyCGp0'
        playlist_uri = "spotify:user:#{user_id}:playlist:#{playlist_id}"

        playlist_url = "http://open.spotify.com/user/#{user_id}/playlist/#{playlist_id}"
        expect(PlaylistService).to receive(:create_playlist).with(playlist_id, user_id, playlist_uri)
        post '/playlists', playlist_url: playlist_url
      end
    end
  end
end
