require 'yaml'

class CacheHandler
  class << self
    CACHE_FILE_NAME = '.cache'

    def get_enabled_users
      cache = get_cache 'enabled_users'
      cache['enabled_users'] || []
    end

    def get_user_mappings
      cache = get_cache 'user_mappings'
      cache['user_mappings'] || {}
    end

    def get_track_history
      cache = get_cache 'track_history'
      cache['track_history'] || []
    end

    def cache_enabled_users! users
      cache! 'enabled_users', users
    end

    def cache_user_mappings! mappings
      cache! 'user_mappings', mappings
    end

    def cache_track_history! history
      cache! 'track_history', history
    end

    private
    def get_cache type
      cache = File.exists?(CACHE_FILE_NAME) ? YAML.load_file(CACHE_FILE_NAME) : {}
      cache
    end

    def cache! type, object
      cache = get_cache type
      cache[type] = object
      File.open(CACHE_FILE_NAME, 'w+') do |f|
        f.write cache.to_yaml
      end
    end
  end
end
