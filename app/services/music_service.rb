class MusicService < ServiceBase
  class << self
    def playing?
      spotify_wrapper.playing?
    end

    def skip!
      spotify_wrapper.skip!
    end

    def stop!
      spotify_wrapper.stop!
    end

    def play!
      spotify_wrapper.play!
    end

    def play(track)
      spotify_wrapper.play_track track.spotify_track
    end
  end
end
