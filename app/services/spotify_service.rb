class SpotifyService
  PLAY_URL = 'https://whatever.spotilocal.com:4371/remote/play.json?csrf=%{csrf_token}&oauth=%{oauth_token}&uri=spotify:track:%{track_id}'
  STATUS_URL = 'https://whatever.spotilocal.com:4371/remote/status.json?csrf=%{csrf_token}&oauth=%{oauth_token}'
  PAUSE_URL = 'https://whatever.spotilocal.com:4371/remote/pause.json?csrf=%{csrf_token}&oauth=%{oauth_token}&pause=%{pause}'
  OAUTH_TOKEN_URL = 'https://open.spotify.com/token'
  CSRF_TOKEN_URL = 'https://whatever.spotilocal.com:4371/simplecsrf/token.json?&ref=&cors='
  CSRF_REQUEST_ORIGIN = 'https://embed.spotify.com'

  class << self
    def play(track)
      play_url = PLAY_URL % { csrf_token: get_csrf_token,
                              oauth_token: get_oauth_token,
                              track_id: track.id }
      make_the_call play_url
    end

    def end_of_song?
      status_url = STATUS_URL % { csrf_token: get_csrf_token,
                                  oauth_token: get_oauth_token }
      response_body = make_the_call status_url
      JSON.parse(response_body)['playing_position'] == 0
    end

    def pause(pause=true)
      pause_url = PAUSE_URL % { csrf_token: get_csrf_token,
                                oauth_token: get_oauth_token,
                                pause: pause }
      make_the_call pause_url
    end

    private

    def make_the_call url
      attempts = 0
      while(attempts < 5)
        begin
          attempts += 1
          response = RestClient.get URI.encode(url)
          return response.body
        rescue RestClient::BadRequest => e
          puts e
          next
        end
      end
    end

    def get_oauth_token
      response = RestClient.get(OAUTH_TOKEN_URL)
      JSON.parse(response.body)['t']
    end

    def get_csrf_token
      response = RestClient.get(CSRF_TOKEN_URL, { 'Origin' => CSRF_REQUEST_ORIGIN })
      JSON.parse(response.body)['token']
    end
  end
end
