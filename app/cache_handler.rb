require 'yaml'

class CacheHandler
  class << self
    def get_enabled_users
      cache = get_cache
      return [] if cache.nil? or cache['users'].nil? or cache['users']['enabled'].nil?
      cache['users']['enabled']
    end

    def get_user_mappings
      cache = get_cache
      return {} if cache.nil? or cache['users'].nil? or cache['users']['mappings'].nil?
      cache['users']['mappings']
    end

    def cache_enabled! users
      cache = get_cache
      cache['users']['enabled'] = users
      File.open('.cache', 'w+') do |f|
        f.write cache.to_yaml
      end
    end

    def cache_user_mappings! mappings
      cache = get_cache
      cache['users']['mappings'] = mappings
      File.open('.cache', 'w+') do |f|
        f.write cache.to_yaml
      end
    end

    private
    def get_cache
      cache = File.exists?('.cache') ? YAML.load_file('.cache') : {}
      cache['users'] ||= {}
      cache
    end

  end
end
