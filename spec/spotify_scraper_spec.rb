require_relative 'spec_helper'

describe SpotifyScraper do
  context 'name_and_image_from_spotify_id' do
    it 'should set the image_url if it is found' do
      mock_response = { 'display_name' => 'DISPLAY NAME',
                        'images' => [ { 'url' => 'http://image.com' } ] }.to_json
      spotify_user_id = 123
      url = SpotifyScraper::SPOTIFY_PROFILE_URL_FORMAT % spotify_user_id
      allow(RestClient).to receive(:get).and_return(mock_response)
      name_and_url = SpotifyScraper.name_and_image_from_spotify_id spotify_user_id
      expect(name_and_url[:name]).to eq('DISPLAY NAME')
      expect(name_and_url[:image_url]).to eq('http://image.com')
    end

    it 'should set the image_url to nil if it is not found' do
      mock_response = { 'display_name' => 'DISPLAY NAME',
                        'images' => [] }.to_json
      spotify_user_id = 123
      allow(RestClient).to receive(:get).and_return(mock_response)
      name_and_url = SpotifyScraper.name_and_image_from_spotify_id spotify_user_id
      expect(name_and_url[:image_url]).to be nil
    end

    it 'should use the correct url format' do
      mock_response = { 'display_name' => '',
                        'images' => [] }.to_json
      spotify_user_id = 123
      url = SpotifyScraper::SPOTIFY_PROFILE_URL_FORMAT % spotify_user_id
      expect(RestClient).to receive(:get).with(url).and_return(mock_response)
      SpotifyScraper.name_and_image_from_spotify_id spotify_user_id
    end
  end
end
