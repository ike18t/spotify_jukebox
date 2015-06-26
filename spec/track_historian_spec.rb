require_relative 'spec_helper'

describe TrackHistorian do
  before do
    allow(CacheService).to receive(:get_track_history).and_return([])
    allow(CacheService).to receive(:cache_track_history!)
    @track_historian = TrackHistorian.new
  end

  context 'initialize' do
    it 'should pull history from cache' do
      track_history = [:a, :b, :c]
      allow(CacheService).to receive(:get_track_history).and_return(track_history)
      @track_historian = TrackHistorian.new
      expect(@track_historian.instance_variable_get(:@track_history)).to eq(track_history)
    end
  end

  context 'update_enabled_playlists_list' do
    it 'should update enabled playlist list should do what its name implies' do
      dummy_list = [:a, :b]
      @track_historian.update_enabled_playlists_list dummy_list
      expect(@track_historian.instance_variable_get(:@enabled_playlists)).to eq(dummy_list)
    end
  end

  context 'update_playlist_track_count' do
    it 'should store the playlist count key value pair in the playlist_track_counts instance variable' do
      playlist, count = Playlist.new(:name => 'bah'), 2
      @track_historian.update_playlist_track_count playlist, count
      expect(@track_historian.instance_variable_get(:@playlist_track_counts)).to eq({playlist.name => count})
    end
  end

  context 'record' do
    it 'should add track key to the array' do
      track_key = { 'artist' => 'track'}
      @track_historian.instance_variable_set(:@track_history, [])
      allow(@track_historian).to receive(:generate_track_key).and_return(track_key)
      allow(@track_historian).to receive(:get_calculated_size).and_return(1)
      @track_historian.record 'artist', 'track'
      expect(@track_historian.instance_variable_get(:@track_history)).to include(track_key)
    end

    it 'should bump value in index 0 if max size has been met' do
      track_key = { 'artist' => 'track' }
      @track_historian.instance_variable_set(:@track_history, [:a, :b, :c])
      allow(@track_historian).to receive(:get_calculated_size).and_return(3)
      @track_historian.record 'artist', 'track'
      expect(@track_historian.instance_variable_get(:@track_history)).to eq([:b, :c, track_key])
    end

    it 'should persist history to cache' do
      @track_historian.instance_variable_set(:@track_history, [:a, :b, :c])
      allow(@track_historian).to receive(:generate_track_key).and_return(:d)
      allow(@track_historian).to receive(:get_calculated_size).and_return(3)
      expect(CacheService).to receive(:cache_track_history!).with(@track_historian.instance_variable_get(:@track_history))
      @track_historian.record 'artist', 'track'
    end
  end

  context 'played_recently?' do
    it 'should return true if the track key is in the track_history array' do
      track_key = { 'artist' => 'track' }
      @track_historian.instance_variable_set(:@track_history, [:a, track_key, :c])
      allow(@track_historian).to receive(:generate_track_key).and_return(track_key)
      expect(@track_historian.played_recently?('artist', 'track')).to be true
    end

    it 'should return false if the track key is not in the track_history array' do
      track_key = 'artist => track'
      @track_historian.instance_variable_set(:@track_history, [:a, :b, :c])
      allow(@track_historian).to receive(:generate_track_key).and_return(track_key)
      expect(@track_historian.played_recently?('artist', 'track')).to be false
    end
  end

  context 'pop' do
    it 'should bump value in index 0' do
      @track_historian.instance_variable_set(:@track_history, [:a, :b, :c])
      @track_historian.pop
      expect(@track_historian.instance_variable_get(:@track_history)).to eq([:b, :c])
    end
  end

  context 'get_calculated_size' do
    before do
      @track_historian.instance_variable_set(:@enabled_playlists, ['a', 'b', 'c'])
    end

    it { expect(@track_historian.send(:get_calculated_size)).to eq(0) }

    it 'should add enabled playlists track counts and return 75%' do
      playlist_track_counts = {'a' => 1, 'b' => 4, 'c' => 3}
      @track_historian.instance_variable_set(:@playlist_track_counts, playlist_track_counts)
      expect(@track_historian.send(:get_calculated_size)).to eq(4)
    end

    it 'should not error if an enabled_playlist is not in the list' do
      playlist_track_counts = {'a' => 1, 'c' => 3}
      @track_historian.instance_variable_set(:@playlist_track_counts, playlist_track_counts)
      expect(@track_historian.send(:get_calculated_size)).to eq(2)
    end
  end

end
