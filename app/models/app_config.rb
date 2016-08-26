class AppConfig < ModelBase
  require 'base64'
  require 'aescrypt'

  attr_accessor :username, :password, :app_key

  def password=(value)
    @password = AESCrypt.encrypt(value, get_secret)
  end

  def password
    return nil if @password.nil?
    AESCrypt.decrypt(@password, get_secret)
  end

  def app_key
    return nil if @app_key.nil?
    app_key = File.expand_path(@app_key)
    return nil unless File.exist? app_key
    IO.read(app_key, encoding: 'BINARY')
  end

  private

  def get_secret
    @secret ||= ENV['jukebox_secret'] || ''
  end
end
