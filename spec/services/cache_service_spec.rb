require_relative '../spec_helper'

describe CacheService do
  context 'get_cache' do
    it 'should return empty playlists array if file does not exist' do
      File.stubs(:exists?).returns(false)
      CacheService.get_playlists.should eq([])
    end

    it 'should return empty track_history array if file does not exist' do
      File.stubs(:exists?).returns(false)
      CacheService.get_track_history.should eq([])
    end

    it 'should read users hash from file' do
      hash = {'users' => { :a => 'a', :b => 'b' }}
      File.stubs(:exists?).returns(true)
      YAML.stubs(:load_file).returns(hash)
      CacheService.send(:get_cache, 'users').should eq(hash)
    end
  end

  context 'cache!' do
    it 'should update hash and write to file as yaml' do
      CacheService.stubs(:get_cache).with('name').returns({})
      file = double('file')
      File.should_receive(:open).and_yield(file)
      file.should_receive(:write).with({'name' => 'ike'}.to_yaml)
      CacheService.send(:cache!, 'name', 'ike')
    end
  end

  context 'get_playlists' do
    it 'should return [] if cache does not contain a enabled key' do
      CacheService.stubs(:get_cache).with('playlists').returns({})
      CacheService.get_playlists.should eq([])
    end

    it 'should return playlists from hash' do
      expected = [:a, :b, :c]
      CacheService.stubs(:get_cache).with('playlists').returns({ 'playlists' => expected })
      CacheService.get_playlists.should eq(expected)
    end
  end

  context 'cache_playlists!' do
    it 'should call cache! with the appropriate params' do
      playlists = {:a => 'a'}
      expect(CacheService).to receive(:cache!).with('playlists', playlists)
      CacheService.cache_playlists! playlists
    end
  end

  context 'get_track_history' do
    it 'should return [] if cache does not contain a track_history key' do
      CacheService.stubs(:get_cache).with('track_history').returns({})
      CacheService.get_track_history.should eq([])
    end

    it 'should return enabled list from hash' do
      expected = [:a, :b, :c]
      CacheService.stubs(:get_cache).with('track_history').returns({ 'track_history' => expected })
      CacheService.get_track_history.should eq(expected)
    end
  end

  context 'cache_track_history!' do
    it 'should call cache! with the appropriate params' do
      track_history = {:a => 'a'}
      expect(CacheService).to receive(:cache!).with('track_history', track_history)
      CacheService.cache_track_history! track_history
    end
  end
end
