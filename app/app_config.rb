class AppConfig
  attr_reader :username, :password, :playlist_uri, :app_key

  def initialize params={}
    params.each do |key, value|
      instance_variable_set "@#{key}", value
    end
  end
end
