class User < ModelBase
  attr_accessor :name
  attr_writer :enabled
  attr_reader :id, :image_url

  def enabled?
    @enabled == true
  end
end
