require 'open-uri'
require 'nokogiri'

module SpotifyScraper
  def self.name_and_image_from_spotify_id(spotify_id)
    doc = Nokogiri::HTML(open("http://open.spotify.com/user/#{spotify_id}"))
    name = doc.css("meta[property='og:title']").first['content']
    image_url = doc.css("meta[property='og:image']").first['content']
    { :name => name, :image_url => image_url }
  end
end
