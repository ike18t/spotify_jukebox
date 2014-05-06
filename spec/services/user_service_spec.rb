require_relative '../spec_helper'

describe UserService do
  context 'create_user' do
    it 'should not add the user if it already exists' do
      allow(SpotifyScraper).to receive(:name_and_image_from_spotify_id).once
      existing = [ User.new(:id => 123) ]
      allow(UserService).to receive(:get_users).once.and_return(existing);
      expect(UserService).to receive(:save_users).never
      UserService.create_user 123
    end

    it 'should add new user object to user cache' do
      allow(SpotifyScraper).to receive(:name_and_image_from_spotify_id).and_return({})
      existing = [ double(:id => 123) ]
      expect(UserService).to receive(:get_users).once.and_return(existing);
      expect(UserService).to receive(:save_users).once
      user = UserService.create_user 321
      existing.include? user
    end

    it 'should set the users name and image_url from the return value of the scraper' do
      allow(UserService).to receive(:get_users).and_return([])
      allow(UserService).to receive(:save_users).once
      expect(SpotifyScraper).to receive(:name_and_image_from_spotify_id).with(123).once.and_return({ :name => 'some_name', :image_url => 'some_url' })
      user = UserService.create_user 123
      user.name.should eq('some_name')
      user.image_url.should eq('some_url')
    end
  end

  context 'get_enabled_users' do
    it 'should get users' do
      expect(UserService).to receive(:get_users).once.and_return({})
      UserService.get_enabled_users
    end

    it 'should only return users that are enabled' do
      enabled =  [ User.new(:id => 321, :name => 'name321', :image_url => 'url321', :enabled => true),
                   User.new(:id => 567, :name => 'name567', :image_url => 'url567', :enabled => true) ]
      disabled = [ User.new(:id => 123, :name => 'name123', :image_url => 'url123', :enabled => false) ]

      expect(UserService).to receive(:get_users).and_return(enabled + disabled)
      UserService.get_enabled_users.should eq(enabled)
    end
  end

  context 'get_users' do
    it 'should get users from cache' do
      expect(CacheService).to receive(:get_users)
      UserService.get_users
    end
  end

  context 'save_users' do
    it 'should save users to cache' do
      expect(CacheService).to receive(:cache_users!).with({})
      UserService.send(:save_users, {})
    end
  end

  context 'enable_user' do
    it 'should set enabled flag on user' do
      users = [ User.new(:id => 123, :name => 'name123', :image_url => 'url123', :enabled => false) ]
      expect(UserService).to receive(:get_users).and_return(users)
      expect(UserService).to receive(:save_users)
      UserService.enable_user 123
      users[0].enabled?.should eq(true)
    end

    it 'should not save changes if user does not exist' do
      allow(UserService).to receive(:get_users).and_return([])
      expect(UserService).to receive(:save_users).never
      UserService.enable_user 123
    end
  end

  context 'disable_user' do
    it 'should set enabled flag on user' do
      users = [ User.new(:id => 123, :name => 'name123', :image_url => 'url123', :enabled => true) ]
      allow(UserService).to receive(:get_users).and_return(users)
      allow(UserService).to receive(:save_users)
      UserService.disable_user 123
      users[0].enabled?.should eq(false)
    end

    it 'should not save changes if user does not exist' do
      allow(UserService).to receive(:get_users).and_return([])
      expect(UserService).to receive(:save_users).never
      UserService.disable_user 123
    end
  end
end
