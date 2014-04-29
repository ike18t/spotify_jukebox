require_relative 'spec_helper'

describe CacheHandler do
  context 'get_cache' do
    it 'should return empty users hash if file does not exist' do
      File.stubs(:exists?).returns(false)
      CacheHandler.send(:get_cache, 'users').should eq({})
    end

    it 'should read users hash from file' do
      hash = {'users' => { :a => 'a', :b => 'b' }}
      File.stubs(:exists?).returns(true)
      YAML.stubs(:load_file).returns(hash)
      CacheHandler.send(:get_cache, 'users').should eq(hash)
    end
  end

  context 'cache!' do
    it 'should update hash and write to file as yaml' do
      CacheHandler.stubs(:get_cache).with('name').returns({})
      file = double('file')
      File.should_receive(:open).and_yield(file)
      file.should_receive(:write).with({'name' => 'ike'}.to_yaml)
      CacheHandler.send(:cache!, 'name', 'ike')
    end
  end

  context 'get_playlists' do
    it 'should return [] if cache does not contain a enabled key' do
      CacheHandler.stubs(:get_cache).with('playlists').returns({})
      CacheHandler.get_playlists.should eq([])
    end

    it 'should return playlists from hash' do
      expected = [:a, :b, :c]
      CacheHandler.stubs(:get_cache).with('playlists').returns({ 'playlists' => expected })
      CacheHandler.get_playlists.should eq(expected)
    end
  end

  context 'cache_playlists!' do
    it 'should call cache! with the appropriate params' do
      playlists = {:a => 'a'}
      expect(CacheHandler).to receive(:cache!).with('playlists', playlists)
      CacheHandler.cache_playlists! playlists
    end
  end

  context 'get_track_history' do
    it 'should return [] if cache does not contain a track_history key' do
      CacheHandler.stubs(:get_cache).with('track_history').returns({})
      CacheHandler.get_track_history.should eq([])
    end

    it 'should return enabled list from hash' do
      expected = [:a, :b, :c]
      CacheHandler.stubs(:get_cache).with('track_history').returns({ 'track_history' => expected })
      CacheHandler.get_track_history.should eq(expected)
    end
  end

  context 'cache_track_history!' do
    it 'should call cache! with the appropriate params' do
      track_history = {:a => 'a'}
      expect(CacheHandler).to receive(:cache!).with('track_history', track_history)
      CacheHandler.cache_track_history! track_history
    end
  end
end
