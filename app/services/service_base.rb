class ServiceBase
  protected
  def self.spotify_wrapper
    @@spotify_wrapper ||= SpotifyWrapper.new(ConfigService.get)
  end
end
