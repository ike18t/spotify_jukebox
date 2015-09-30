require_relative 'spec_helper'

describe JukeboxWeb do
  def app
    JukeboxWeb
  end

  describe '/playlists' do
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

  describe '/users/:user_id/playlists' do
    context 'post' do
      before do
        allow(PlaylistService).to receive(:create_playlist)
        allow(UserService).to receive(:get_users).and_return([])
        allow(PlaylistService).to receive(:get_playlists).and_return([])
      end

      it 'should create a playlist for the posted user out of the playlist_url posted' do
        user_id = '123'
        playlist_id = '7Co7hqxAQFSAV7bMtyCGp0'
        playlist_uri = "spotify:user:1295855412:playlist:#{playlist_id}"

        playlist_url = "http://open.spotify.com/user/1295855412/playlist/#{playlist_id}"
        expect(PlaylistService).to receive(:create_playlist).with(playlist_id, user_id, playlist_uri)
        post "/users/#{user_id}/playlists", playlist_url: playlist_url
      end

      it 'should notify sockets of changes' do
        app.sockets = [double, double]

        user_id = '123'
        playlist_url = "http://open.spotify.com/user/1295855412/playlist/7Co7hqxAQFSAV7bMtyCGp0"

        message = { users: [], playlists: [] }.to_json
        expect(app.sockets[0]).to receive(:send).with(message)
        expect(app.sockets[1]).to receive(:send).with(message)
        post "/users/#{user_id}/playlists", playlist_url: playlist_url

        app.sockets = []
      end

      it 'should return ok' do
        user_id = '123'
        playlist_url = "http://open.spotify.com/user/1295855412/playlist/7Co7hqxAQFSAV7bMtyCGp0"


        post "/users/#{user_id}/playlists", playlist_url: playlist_url
        expect(last_response).to be_ok
      end
    end
  end
end
