require 'yaml'
require 'leveldb'

class CacheService

  CACHE_TYPES = [:playlists, :track_history, :users]

  class << self
    CACHE_TYPES.each do |type|
      type = type.to_s

      define_method("get_#{type}") do
        value = data_store[type]
        value.nil? ? [] : YAML::load(value)
      end

      define_method("cache_#{type}!") do |value|
        data_store[type] = value.to_yaml
      end
    end

    private
    def data_store
      @@leveldb ||= LevelDB::DB.new '.cache'
    end
  end
end
