require 'open-uri'
require 'nokogiri'

class SpotifyScraper
  def self.name_from_spotify_id(spotify_id)
      doc = Nokogiri::HTML(open("http://open.spotify.com/user/#{spotify_id}"))
      doc.css("meta[property='og:title']").first['content']
  end
end
