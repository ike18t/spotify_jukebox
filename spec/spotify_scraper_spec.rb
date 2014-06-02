require_relative 'spec_helper'

describe SpotifyScraper do
  context 'name_and_image_from_spotify_id' do
    it 'should set the image_url if it is found' do
      str = <<-HTML
        <head>
          <meta property="og:title" content="idatlof">
          <meta property="og:image" content="http://google.com/ike.jpg">
        </head>
      HTML
      allow(SpotifyScraper).to receive(:open).and_return(str)
      name_and_url = SpotifyScraper.name_and_image_from_spotify_id 123
      expect(name_and_url[:name]).to eq('idatlof')
      expect(name_and_url[:image_url]).to eq('http://google.com/ike.jpg')
    end

    it 'should set the image_url to nil if it is not found' do
      str = <<-HTML
        <head>
          <meta property="og:title" content="idatlof">
        </head>
      HTML
      allow(SpotifyScraper).to receive(:open).and_return(str)
      name_and_url = SpotifyScraper.name_and_image_from_spotify_id 123
      expect(name_and_url[:name]).to eq('idatlof')
      expect(name_and_url[:image_url]).to be nil
    end
  end
end
