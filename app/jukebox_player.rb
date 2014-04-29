require_relative 'cache_handler'

class JukeboxPlayer

  attr_accessor :spotify_wrapper
  def initialize spotify_wrapper, message_queue, track_historian
    @spotify_wrapper = spotify_wrapper
    @historian = track_historian
    @message_queue = message_queue
  end

  def start!
    playlists = CacheHandler.get_playlists

    current_playlist = nil
    loop do
      enabled_playlists = CacheHandler.get_playlists.keep_if {|p| p.enabled?}
      @historian.update_enabled_playlists_list enabled_playlists.map{|p| p.name}
      if not enabled_playlists.empty?
        current_playlist = get_next_playlist enabled_playlists, current_playlist
        track = get_random_track_for_playlist current_playlist
      end
      next if track.nil?
      notify_metadata(track, current_playlist)
      @spotify_wrapper.play_track(track)
    end
  end

  private

  def notify_metadata(track, playlist)
    metadata = @spotify_wrapper.get_track_metadata(track).merge({ :playlist => playlist.name })
    @historian.record metadata[:artists], metadata[:name]
    $logger.info "Now playing #{metadata[:name]} by #{metadata[:artists]} on the album #{metadata[:album]}"
    @message_queue.push(metadata)
  end

  def get_random_track_for_playlist playlist
    tracks = @spotify_wrapper.get_tracks_for_playlist playlist
    @historian.update_playlist_track_count playlist, tracks.count
    tracks.reject! do |track|
      metadata = @spotify_wrapper.get_track_metadata track
      @historian.played_recently?(metadata[:artists], metadata[:name])
    end
    tracks.sample
  end

  def get_next_playlist enabled_playlists, last_playlist
    last_index = enabled_playlists.index(last_playlist) || rand(enabled_playlists.count)
    enabled_playlists.rotate! last_index + 1
    enabled_playlists.first
  end

end
