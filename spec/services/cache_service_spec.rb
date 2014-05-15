require_relative '../spec_helper'

describe CacheService do

  before do
    @data_store = {}
    allow(CacheService).to receive(:data_store).and_return(@data_store);
  end

  context 'get_cache' do
    CacheService::CACHE_TYPES.each do |type|
      type = type.to_s

      context "get_#{type}" do
        it 'should return an empty array if the key is not in cache' do
          CacheService.get_playlists.should eq([])
        end

        it "should read #{type} hash from cache source" do
          hash = {type => { :a => 'a', :b => 'b' }}
          @data_store[type] = hash.to_yaml
          CacheService.send("get_#{type}").should eq(hash)
        end
      end
    end
  end

  context 'cache_type!' do
    CacheService::CACHE_TYPES.each do |type|
      type = type.to_s

      context "cache_#{type}!" do
        it "should update #{type} hash and write to file as yaml" do
          hash = {type => { :a => 'a', :b => 'b' }}
          CacheService.send("cache_#{type}!", hash)
          YAML::load(@data_store[type]).should eq(hash)
        end
      end
    end
  end
end
