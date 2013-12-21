class AppConfig
  require 'base64'
  require 'aescrypt'

  attr_accessor :username, :password, :playlist_uri, :api_key

  def initialize params={}
    params.each do |key, value|
      instance_variable_set "@#{key}", value
    end
  end

  def password= value
    @password = AESCrypt.encrypt(value, 'secret_key')
  end

  def password
    return nil if @password.nil?
    AESCrypt.decrypt(@password, 'secret_key') unless @password.nil?
  end

  def api_key
    return nil if @api_key.nil?
    api_key = File.expand_path(@api_key)
    return nil unless File.exists? api_key
    IO.read(api_key, encoding: 'BINARY')
  end
end
