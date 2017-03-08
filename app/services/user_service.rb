class UserService
  class << self
    def create_user(user_id)
      users = get_users
      if users.select { |u| u.id == user_id }.empty?
        user_name = get_name(user_id)
        user = User.new id: user_id, name: user_name
        users << user
        save_users users
      end
      user
    end

    def get_enabled_users
      users = get_users
      users.select(&:enabled?)
    end

    def remove_user(id)
      users = get_users
      users.reject! { |p| p.id == id }
      PlaylistService.get_playlists_for_user(id).each do |playlist|
        PlaylistService.remove_playlist playlist.id
      end
      save_users users
    end

    def enable_user(id)
      set_enabled id, true
    end

    def disable_user(id)
      set_enabled id, false
    end

    def get_users
      CacheService.get_users
    end

    private

    def get_name user_id
      config = ConfigService.get
      RSpotify::authenticate(config.client_id, config.client_secret)
      spotify_user = RSpotify::User.find(user_id)
      spotify_user.display_name
    end

    def set_enabled(user_id, enabled)
      users = get_users
      user_index = users.index { |user| user.id == user_id }
      unless user_index.nil?
        users[user_index].enabled = enabled
        save_users users
      end
    end

    def save_users(users)
      CacheService.cache_users! users
    end
  end
end
