require 'open-uri'
require 'rest-client'

module SpotifyScraper
  SPOTIFY_PROFILE_URL_FORMAT = 'https://api.spotify.com/v1/users/%s'

  def self.name_and_image_from_spotify_id(spotify_id)
    profile_url = SPOTIFY_PROFILE_URL_FORMAT % spotify_id
    response = JSON.parse(RestClient.get(profile_url))
    name = response['display_name']
    images = response['images']
    image_url = images.empty? ? nil : images.first['url']
    { :name => name, :image_url => image_url }
  end
end
