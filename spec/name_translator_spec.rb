require_relative 'spec_helper'

describe NameTranslator do
  context 'get_for' do
    it 'should return name from cache if it is cached' do
      CacheHandler.stubs(:get_user_mappings).returns({:a => 'a', :b => 'b'})
      CacheHandler.stubs(:cache_user_mappings!)
      NameTranslator.get_for(:a).should eq('a')
    end

    it 'should scrape name if not cached' do
      CacheHandler.stubs(:get_user_mappings).returns({:a => 'a', :b => 'b'})
      CacheHandler.stubs(:cache_user_mappings!)
      SpotifyScraper.stubs(:name_from_spotify_id).with(:c).returns('c')
      NameTranslator.get_for(:c).should eq('c')
    end

    it 'should store scraped name if not cached' do
      from_cache = {:a => 'a', :b => 'b'}
      CacheHandler.stubs(:get_user_mappings).returns(from_cache)
      SpotifyScraper.stubs(:name_from_spotify_id).with(:c).returns('c')
      CacheHandler.stubs(:cache_user_mappings!).with(from_cache.merge({:c => 'c'}))
      NameTranslator.get_for(:c).should eq('c')
    end
  end
end
