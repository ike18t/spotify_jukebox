class ServiceBase
  class << self
    protected

    def spotify_wrapper
      @@spotify_wrapper ||= SpotifyWrapper.new(ConfigService.get)
    end
  end
end
