require_relative 'spotify_scraper'

class NameTranslator
  def self.get_for user_name
    @user_mapping_cache = CacheHandler.get_user_mappings
    if not @user_mapping_cache.keys.include? user_name
      $logger.info "pulling user #{user_name} display name"
      @user_mapping_cache[user_name] = SpotifyScraper.name_from_spotify_id(user_name)
      CacheHandler.cache_user_mappings! @user_mapping_cache
    end
    @user_mapping_cache[user_name]
  end
end
