class TrackHistorian
  require 'spotify'

  TRACK_FORMAT = '%s => %s'

  def initialize
    @user_track_counts = {}
    @track_history = []
    @enabled_users = []
  end

  def update_enabled_users_list enabled_users
    @enabled_users = enabled_users
  end

  def update_user_track_count user, count
    @user_track_counts[user] = count
  end

  def record track
    @track_history.push generate_track_key(track)
    @track_history.shift if @track_history.size > get_calculated_size
  end

  def played_recently? track
    track_key = generate_track_key(track)
    not @track_history.index(track_key).nil?
  end

  protected

  def generate_track_key track
    TRACK_FORMAT % [ Spotify.artist_name(Spotify.track_artist(track, 0)), Spotify.track_name(track) ]
  end

  def get_calculated_size
    @enabled_users.inject(0){ |count, user| count + (@user_track_counts[user] || 0) } * 0.50
  end

end
