class AppConfig
  require 'base64'
  require 'aescrypt'

  attr_accessor :username, :password, :playlist_uri, :app_key

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

  def app_key
    return nil if @app_key.nil?
    app_key = File.expand_path(@app_key)
    return nil unless File.exists? app_key
    IO.read(app_key, encoding: 'BINARY')
  end
end
