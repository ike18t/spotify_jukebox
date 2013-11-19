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

  context 'get_enabled_users' do
    it 'should return [] if cache does not contain a enabled key' do
      CacheHandler.stubs(:get_cache).with('enabled_users').returns({})
      CacheHandler.get_enabled_users.should eq([])
    end

    it 'should return enabled list from hash' do
      expected = [:a, :b, :c]
      CacheHandler.stubs(:get_cache).with('enabled_users').returns({ 'enabled_users' => expected })
      CacheHandler.get_enabled_users.should eq(expected)
    end
  end

  context 'cache_enabled_users!' do
    it 'should call cache! with the appropriate params' do
      users = {:a => 'a'}
      expect(CacheHandler).to receive(:cache!).with('enabled_users', users)
      CacheHandler.cache_enabled_users! users
    end
  end

  context 'get_user_mappings' do
    it 'should return {} if cache does not contain a mappings key' do
      CacheHandler.stubs(:get_cache).with('user_mappings').returns({})
      CacheHandler.get_user_mappings.should eq({})
    end

    it 'should return mappings list from hash' do
      expected = {:a => 'a', :b => 'b', :c => 'c'}
      CacheHandler.stubs(:get_cache).with('user_mappings').returns({ 'user_mappings' => expected })
      CacheHandler.get_user_mappings.should eq(expected)
    end
  end

  context 'cache_user_mappings!' do
    it 'should call cache! with the appropriate params' do
      mappings = {:a => 'a'}
      expect(CacheHandler).to receive(:cache!).with('user_mappings', mappings)
      CacheHandler.cache_user_mappings! mappings
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
