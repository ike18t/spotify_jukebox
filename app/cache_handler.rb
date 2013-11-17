require 'yaml'

class CacheHandler
  class << self
    CACHE_FILE_NAME = '.cache'

    def get_enabled_users
      cache = get_cache
      return [] if cache['users']['enabled'].nil?
      cache['users']['enabled']
    end

    def get_user_mappings
      cache = get_cache
      return {} if cache.nil? or cache['users'].nil? or cache['users']['mappings'].nil?
      cache['users']['mappings']
    end

    def cache_enabled_users! users
      cache! 'enabled', users
    end

    def cache_user_mappings! mappings
      cache! 'mappings', mappings
    end

    private
    def get_cache
      cache = File.exists?(CACHE_FILE_NAME) ? YAML.load_file(CACHE_FILE_NAME) : {}
      cache['users'] ||= {}
      cache
    end

    def cache! type, object
      cache = get_cache
      cache['users'][type] = object
      File.open(CACHE_FILE_NAME, 'w+') do |f|
        f.write cache.to_yaml
      end
    end
  end
end
