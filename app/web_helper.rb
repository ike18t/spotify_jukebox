module WebHelper
  class << self
    def get_playlist_id_and_user_id_from_url url
      match_data = url.match /^.*user\/(.*)\/playlist\/(.*)$/
      { :user_id => match_data[1], :playlist_id => match_data[2] }
    end

    def create_playlist_uri playlist_id, owner_id
      uri_format = 'spotify:user:%s:playlist:%s'
      uri_format % [owner_id, playlist_id]
    end

    def track_info_to_json track, user
      { :current_track => { :name => track.name,
                            :artists => track.artists.join(', '),
                            :album => track.album.name,
                            :image => track.album.art_hex,
                            :user => { :id => user.id, :name => user.name, :avatar_url => user.image_url }
                          } }.to_json.to_s
    end
  end
end
