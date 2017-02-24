class AppConfig < ModelBase
  require 'base64'
  require 'aescrypt'

  attr_accessor :username, :password, :app_key, :client_id, :client_secret

  def password=(value)
    @password = AESCrypt.encrypt(value, get_secret)
  end

  def password
    return nil if @password.nil?
    AESCrypt.decrypt(@password, get_secret)
  end

  def client_secret=(value)
    @client_secret = AESCrypt.encrypt(value, get_secret)
  end

  def client_secret
    return nil if @client_secret.nil?
    AESCrypt.decrypt(@client_secret, get_secret)
  end

  def app_key
    return nil if @app_key.nil?
    app_key = File.expand_path(@app_key)
    return nil unless File.exist? app_key
    IO.read(app_key, encoding: 'BINARY')
  end

  private

  def get_secret
    @secret ||= ENV['JUKEBOX_SECRET'] || ''
  end
end
