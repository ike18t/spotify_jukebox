class ConfigLoader
  require 'yaml'
  require_relative 'app_config'

  def self.load
    appkey = IO.read(File.join(APP_ROOT, 'keys/spotify_appkey.key'), encoding: 'BINARY')

    config = YAML.load_file('config.yml')
    config['app_key'] = appkey
    AppConfig.new config
  end
end
