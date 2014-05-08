require_relative 'spec_helper'

describe WebHelper do
  context 'get_playlist_id_and_user_id_from_url' do
    it 'should pull the user id from the url' do
      url = 'http://web.spotify.com/user/ike/playlist/weezer'
      result = WebHelper.get_playlist_id_and_user_id_from_url url
      result[:user_id].should eq('ike')
    end

    it 'should pull the playlist id from the url' do
      url = 'http://web.spotify.com/user/ike/playlist/weezer'
      result = WebHelper.get_playlist_id_and_user_id_from_url url
      result[:playlist_id].should eq('weezer')
    end
  end

  context 'create_playlist_uri' do
    it 'should return the playlist in the appropriate format' do
      expected = 'spotify:user:ike:playlist:weezer'
      WebHelper.create_playlist_uri('weezer', 'ike').should eq(expected)
    end
  end

  context 'track_info_to_json' do
    it 'should return a json string in the appropriate format' do
      album = Album.new :name => 'blue', :art_hex => 'abc'
      user = User.new :name => 'ike'
      track = Track.new :name => 'say it aint so', :artists => ['weezer'], :album => album
      retVal = WebHelper.track_info_to_json track, user
      json = JSON.parse(retVal)
      json['current_track']['name'].should eq(track.name)
      json['current_track']['artists'].should eq(track.artists.join(', '))
      json['current_track']['album'].should eq(album.name)
      json['current_track']['image'].should eq(album.art_hex)
      json['current_track']['user']['name'].should eq(user.name)
    end
  end
end
