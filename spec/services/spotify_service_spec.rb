require_relative '../spec_helper'

describe SpotifyService do
  before(:each) do
    stub_request(:get, SpotifyService::OAUTH_TOKEN_URL).to_return(body: { 't' => 'oauth_token' }.to_json)
    stub_request(:get, SpotifyService::CSRF_TOKEN_URL).with(headers: { 'Origin' => SpotifyService::CSRF_REQUEST_ORIGIN }).to_return(body: { 'token' => 'csrf_token' }.to_json)
  end

  context 'play' do
    it 'should call the play endpoint with the track uri' do
      expected_url = SpotifyService::PLAY_URL % { csrf_token: 'csrf_token',
                                                  oauth_token: 'oauth_token',
                                                  track_id: 'track_id' }
      stub = stub_request :get, expected_url
      SpotifyService.play(double('Track', { id: 'track_id' }))
      expect(stub).to have_been_made.once
    end
  end

  context 'pause' do
    it 'should call the pause endpoint with the pause query param set to true' do
      expected_url = SpotifyService::PAUSE_URL % { csrf_token: 'csrf_token',
                                                   oauth_token: 'oauth_token',
                                                   pause: true }
      stub = stub_request :get, expected_url
      SpotifyService.pause
      expect(stub).to have_been_made.once
    end

    it 'should call the pause endpoint with the pause query param set to the argument value' do
      expected_url = SpotifyService::PAUSE_URL % { csrf_token: 'csrf_token',
                                                   oauth_token: 'oauth_token',
                                                   pause: false }
      stub = stub_request :get, expected_url
      SpotifyService.pause false
      expect(stub).to have_been_made.once
    end
  end

  context 'end_of_song?' do
    it 'should call the status endpoint and return true if the playing position is 0' do
      expected_url = SpotifyService::STATUS_URL % { csrf_token: 'csrf_token',
                                                    oauth_token: 'oauth_token' }
      stub = stub_request(:get, expected_url).to_return(body: { 'playing_position': 0 }.to_json)
      expect(SpotifyService.end_of_song?).to be_truthy
      expect(stub).to have_been_made.once
    end

    it 'should call the status endpoint and return true if the playing position is not 0' do
      expected_url = SpotifyService::STATUS_URL % { csrf_token: 'csrf_token',
                                                    oauth_token: 'oauth_token' }
      stub = stub_request(:get, expected_url).to_return(body: { 'playing_position': 1 }.to_json)
      expect(SpotifyService.end_of_song?).to be_falsy
      expect(stub).to have_been_made.once
    end
  end
end
