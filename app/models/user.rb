class User < ModelBase
  attr_accessor :name, :image_url
  attr_writer :enabled
  attr_reader :id

  def enabled?
    @enabled == true
  end
end
