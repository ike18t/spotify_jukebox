class Playlist
  attr_accessor :name, :url, :enabled

  def initialize params={}
    params.each do |key, value|
      instance_variable_set "@#{key}", value
    end
  end

  def enabled?
    @enabled == true
  end
end
