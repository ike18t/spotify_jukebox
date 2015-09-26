class TrackHistorian
  def initialize
    @playlist_track_counts = {}
    @track_history = CacheService.get_track_history
    @enabled_playlists = []
  end

  def update_enabled_playlists_list(enabled_playlists)
    @enabled_playlists = enabled_playlists
  end

  def update_playlist_track_count(playlist, count)
    @playlist_track_counts[playlist.name] = count
  end

  def pop
    @track_history.shift
    CacheService.cache_track_history! @track_history
  end

  def record(artist_name, track_name)
    @track_history.push(artist_name => track_name)
    @track_history.shift if @track_history.size > get_calculated_size
    CacheService.cache_track_history! @track_history
  end

  def played_recently?(artist_name, track_name)
    !@track_history.index(artist_name => track_name).nil?
  end

  protected

  def get_calculated_size
    (@enabled_playlists.inject(0) { |count, playlist| count + (@playlist_track_counts[playlist] || 0) } * 0.50).to_i
  end
end
