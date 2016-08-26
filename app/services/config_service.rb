require 'yaml'

class ConfigService
  class << self
    def update(updates)
      updates.each do |key, value|
        get.send("#{key}=", value)
      end
      save
    end

    def get
      @config ||= read || AppConfig.new
    end

    protected

    FILENAME = 'config.yml'.freeze

    def save
      File.open(FILENAME, 'w+') do |f|
        f.write get.to_yaml
      end
    end

    def read
      config_data = File.read(FILENAME)
      YAML.load(config_data)
    rescue Errno::ENOENT
      nil
    end
  end
end
