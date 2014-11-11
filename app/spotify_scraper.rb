require 'open-uri'
require 'nokogiri'

module SpotifyScraper
  SPOTIFY_PROFILE_URL_FORMAT = 'https://open.spotify.com/user/%s'

  def self.name_and_image_from_spotify_id(spotify_id)
    profile_url = SPOTIFY_PROFILE_URL_FORMAT % spotify_id
    doc = Nokogiri::HTML(open(profile_url))
    name = doc.css("meta[property='og:title']").first['content']
    doc_image = doc.css("meta[property='og:image']")
    image_url = doc_image.empty? ? nil : doc_image.first['content']
    { :name => name, :image_url => image_url }
  end
end
