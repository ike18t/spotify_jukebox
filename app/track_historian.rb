class TrackHistorian

  def initialize
    @user_track_counts = {}
    @track_history = CacheHandler.get_track_history
    @enabled_users = []
  end

  def update_enabled_users_list enabled_users
    @enabled_users = enabled_users
  end

  def update_user_track_count user, count
    @user_track_counts[user] = count
  end

  def record artist_name, track_name
    @track_history.push({ artist_name => track_name })
    @track_history.shift if @track_history.size > get_calculated_size
    CacheHandler.cache_track_history! @track_history
  end

  def played_recently? artist_name, track_name
    not @track_history.index({ artist_name => track_name }).nil?
  end

  protected

  def get_calculated_size
    (@enabled_users.inject(0){ |count, user| count + (@user_track_counts[user] || 0) } * 0.50).to_i
  end

end
