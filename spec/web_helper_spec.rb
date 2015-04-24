require_relative 'spec_helper'

describe WebHelper do
  context 'get_playlist_id_and_user_id_from_url' do
    it 'should pull the user id from the url' do
      url = 'http://web.spotify.com/user/ike/playlist/weezer'
      result = WebHelper.get_playlist_id_and_user_id_from_url url
      expect(result[:user_id]).to eq('ike')
    end

    it 'should pull the playlist id from the url' do
      url = 'http://web.spotify.com/user/ike/playlist/weezer'
      result = WebHelper.get_playlist_id_and_user_id_from_url url
      expect(result[:playlist_id]).to eq('weezer')
    end
  end

  context 'create_playlist_uri' do
    it 'should return the playlist in the appropriate format' do
      expected = 'spotify:user:ike:playlist:weezer'
      expect(WebHelper.create_playlist_uri('weezer', 'ike')).to eq(expected)
    end
  end

  context 'track_info_to_json' do
    it 'should return a json string in the appropriate format' do
      album = Album.new :name => 'blue', :art_hex => 'abc'
      expected_image = WebHelper::IMAGE_URL_FORMAT % album.art_hex
      user = User.new :id => 123, :name => 'ike'
      track = Track.new :name => 'say it aint so', :artists => ['weezer'], :album => album
      retVal = WebHelper.track_info_to_json track, user
      json = JSON.parse(retVal)
      expect(json['current_track']['name']).to eq(track.name)
      expect(json['current_track']['artists']).to eq(track.artists.join(', '))
      expect(json['current_track']['album']).to eq(album.name)
      expect(json['current_track']['image']).to eq(expected_image)
      expect(json['current_user']['id']).to eq(user.id)
      expect(json['current_user']['name']).to eq(user.name)
    end
  end
end
