class Playlist < ModelBase
  attr_accessor :name
  attr_writer :enabled
  attr_reader :user_id, :uri, :id

  def enabled?
    @enabled == true
  end
end
