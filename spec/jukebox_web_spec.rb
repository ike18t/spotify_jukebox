require_relative 'spec_helper'

describe JukeboxWeb do
  def app
    JukeboxWeb
  end

  describe '/playlists' do
    context 'post' do
      it 'should create a playlist out of the playlist_uri posted' do
        user_id = '1295855412'
        playlist_id = '7Co7hqxAQFSAV7bMtyCGp0'

        expect(RSpotify::User).to receive(:find)
                              .with(user_id)
                              .and_return(double('RSpotifyPlaylist', name: 'ike'))
        expect(RSpotify::Playlist).to receive(:find)
                                  .with(user_id, playlist_id)
                                  .and_return(double('RSpotifyPlaylist', name: 'ike\'s playlist'))
        playlist_url = "http://open.spotify.com/user/#{user_id}/playlist/#{playlist_id}"
        post '/playlists', playlist_url: playlist_url
        expect(CacheService.get_playlists.map(&:id)).to include playlist_id
      end

      it 'should create a playlist out of the playlist_url posted' do
        user_id = '1295855412'
        playlist_id = '7Co7hqxAQFSAV7bMtyCGp0'
        playlist_uri = "spotify:user:#{user_id}:playlist:#{playlist_id}"

        expect(RSpotify::User).to receive(:find)
                              .with(user_id)
                              .and_return(double('RSpotifyPlaylist', name: 'ike'))
        expect(RSpotify::Playlist).to receive(:find)
                                  .with(user_id, playlist_id)
                                  .and_return(double('RSpotifyPlaylist', name: 'ike\'s playlist'))
        post '/playlists', playlist_uri: playlist_uri
        expect(CacheService.get_playlists.map(&:id)).to include playlist_id
      end
    end
  end

  describe '/users/:user_id/playlists' do
    context 'post' do
      it 'should create a playlist for the posted user out of the playlist_url posted' do
        user_id = '123'
        playlist_id = '7Co7hqxAQFSAV7bMtyCGp0'
        playlist_uri = "spotify:user:1295855412:playlist:#{playlist_id}"

        playlist_url = "http://open.spotify.com/user/1295855412/playlist/#{playlist_id}"
        expect(PlaylistService).to receive(:create_playlist).with(playlist_id, user_id, playlist_uri)
        post "/users/#{user_id}/playlists", playlist_url: playlist_url
      end

      it 'should create a playlist for the posted user out of the playlist_uri posted' do
        user_id = '123'
        playlist_id = '7Co7hqxAQFSAV7bMtyCGp0'
        playlist_uri = "spotify:user:1295855412:playlist:#{playlist_id}"

        expect(PlaylistService).to receive(:create_playlist).with(playlist_id, user_id, playlist_uri)
        post "/users/#{user_id}/playlists", playlist_uri: playlist_uri
      end

      it 'should notify sockets of changes' do
        app.sockets = [double('socket 1'), double('socket2')]

        user_id = '123'
        playlist_url = 'http://open.spotify.com/user/1295855412/playlist/7Co7hqxAQFSAV7bMtyCGp0'
        message = { playlists: [{ id: '7Co7hqxAQFSAV7bMtyCGp0',
                                  enabled: true,
                                  name: 'ike\'s playlist',
                                  user_id: '123'}],
                    users: [{ id: '123',
                              enabled: false,
                              name: 'ike' }]
                  }.to_json
        allow(RSpotify::User).to receive(:find).and_return(double('RSpotifyUser', name: 'ike'))
        allow(RSpotify::Playlist).to receive(:find).and_return(double('RSpotifyPlaylist', name: 'ike\'s playlist'))
        expect(app.sockets[0]).to receive(:send).with(message)
        expect(app.sockets[1]).to receive(:send).with(message)
        post "/users/#{user_id}/playlists", playlist_url: playlist_url

        app.sockets = []
      end
    end
  end
end
