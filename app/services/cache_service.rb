require 'yaml'
require 'leveldb'

class CacheService
  class << self
    CACHE_TYPES = [:playlists, :track_history, :users]

    CACHE_TYPES.each do |type|
      type = type.to_s

      define_method("get_#{type}") do
        value = leveldb[type]
        value.nil? ? [] : YAML::load(value)
      end

      define_method("cache_#{type}!") do |value|
        leveldb[type] = value.to_yaml
      end
    end

    private
    def leveldb
      @@leveldb ||= LevelDB::DB.new '.cache'
    end
  end
end
