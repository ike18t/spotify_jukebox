require_relative 'spec_helper'

describe SpotifyScraper do
  context 'name_and_image_from_spotify_id' do
    before do
      SpotifyScraper.unstub(:name_and_image_from_spotify_id)
    end

    it 'should set the image_url if it is found' do
      str = <<-HTML
        <head>
          <meta property="og:title" content="idatlof">
          <meta property="og:image" content="http://google.com/ike.jpg">
        </head>
      HTML
      SpotifyScraper.stubs(:open).returns(str)
      name_and_url = SpotifyScraper.name_and_image_from_spotify_id 123
      name_and_url[:name].should eq('idatlof')
      name_and_url[:image_url].should eq('http://google.com/ike.jpg')
    end

    it 'should set the image_url to nil if it is not found' do
      str = <<-HTML
        <head>
          <meta property="og:title" content="idatlof">
        </head>
      HTML
      SpotifyScraper.stubs(:open).returns(str)
      name_and_url = SpotifyScraper.name_and_image_from_spotify_id 123
      name_and_url[:name].should eq('idatlof')
      name_and_url[:image_url].should eq(nil)
    end
  end
end
