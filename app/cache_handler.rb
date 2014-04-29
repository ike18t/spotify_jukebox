require 'yaml'

class CacheHandler
  class << self
    CACHE_FILE_NAME = '.cache'

    CACHE_TYPES = [:playlists, :track_history]

    CACHE_TYPES.each do |type|
      type = type.to_s

      define_method("get_#{type}") do
        cache = get_cache type
        cache[type] || []
      end

      define_method("cache_#{type}!") do |value|
        cache! type, value
      end
    end

    private
    def get_cache type
      cache = File.exists?(CACHE_FILE_NAME) ? YAML.load_file(CACHE_FILE_NAME) : ((type == :playlists) ? [] : {})
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
