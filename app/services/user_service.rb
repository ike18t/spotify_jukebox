class UserService < ServiceBase
  class << self
    def create_user id
      user_info = SpotifyScraper.name_and_image_from_spotify_id id
      users = get_users
      if users.select{ |u| u.id == id }.empty?
        user = User.new :id => id, :name => user_info[:name], :image_url => user_info[:image_url]
        users << user
        save_users users
      end
      user
    end

    def get_enabled_users
      users = get_users
      users.select(&:enabled?)
    end

    def remove_user id
      users = get_users
      users.reject!{ |p| p.id == id }
      PlaylistService.get_playlists_for_user(id).each do |playlist|
        PlaylistService.remove_playlist playlist.id
      end
      save_users users
    end

    def enable_user id
      users = get_users
      user_index = users.index { |user| user.id == id }
      if not user_index.nil?
        users[user_index].enabled = true
        save_users users
      end
    end

    def disable_user id
      users = get_users
      user_index = users.index { |user| user.id == id }
      if not user_index.nil?
        users[user_index].enabled = false
        save_users users
      end
    end

    def get_users
      CacheService.get_users
    end

    private
    def save_users users
      CacheService.cache_users! users
    end
  end
end
