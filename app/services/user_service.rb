class UserService < ServiceBase
  class << self
    def create_user id
      user_info = SpotifyScraper.name_and_image_from_spotify_id id
      users = CacheService.get_users
      if users.select{ |u| u.id == id }.empty?
        user = User.new :id => id, :name => user_info[:name], :image_url => user_info[:image_url]
        users << user
        CacheService.cache_users! users
      end
    end

    def get_enabled_users
      users = CacheService.get_users
      users.select(&:enabled?)
    end

    def get_users
      CacheService.get_users
    end

    def enable_user id
      users = CacheService.get_users
      user_index = users.index { |user| user.id == id }
      users[user_index].enabled = true
      CacheService.cache_users! users
    end

    def disable_user id
      users = CacheService.get_users
      user_index = users.index { |user| user.id == id }
      users[user_index].enabled = false
      CacheService.cache_users! users
    end
  end
end
