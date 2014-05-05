require_relative '../spec_helper'

describe UserService do
  context 'create_user' do
    it 'should not add the user if it already exists' do
      SpotifyScraper.stubs(:name_and_image_from_spotify_id).once
      existing = [ User.new(:id => 123) ]
      UserService.stubs(:get_users).once.returns(existing);
      UserService.unstub(:save_users)
      expect(UserService).to receive(:save_users).never
      UserService.create_user 123
    end

    it 'should add new user object to user cache' do
      SpotifyScraper.stubs(:name_and_image_from_spotify_id).returns({})
      existing = [ double(:id => 123) ]
      UserService.stubs(:get_users).once.returns(existing);
      UserService.unstub(:save_users)
      expect(UserService).to receive(:save_users).once
      user = UserService.create_user 321
      existing.include? user
    end

    it 'should set the users name and image_url from the return value of the scraper' do
      UserService.stubs(:get_users).returns([])
      UserService.stubs(:save_users).once
      SpotifyScraper.should_receive(:name_and_image_from_spotify_id).with(123).once.and_return({ :name => 'some_name', :image_url => 'some_url' })
      user = UserService.create_user 123
      user.name.should eq('some_name')
      user.image_url.should eq('some_url')
    end
  end

  context 'get_enabled_users' do
    it 'should get users' do
      UserService.should_receive(:get_users).once.and_return({})
      UserService.get_enabled_users
    end

    it 'should only return users that are enabled' do
      enabled =  [ User.new(:id => 321, :name => 'name321', :image_url => 'url321', :enabled => true),
                   User.new(:id => 567, :name => 'name567', :image_url => 'url567', :enabled => true) ]
      disabled = [ User.new(:id => 123, :name => 'name123', :image_url => 'url123', :enabled => false) ]

      UserService.should_receive(:get_users).and_return(enabled + disabled)
      UserService.get_enabled_users.should eq(enabled)
    end
  end

  context 'get_users' do
    it 'should get users from cache' do
      UserService.unstub(:get_users)
      CacheService.should_receive(:get_users)
      UserService.get_users
    end
  end

  context 'save_users' do
    it 'should save users to cache' do
      UserService.unstub(:save_users)
      CacheService.should_receive(:cache_users!).with({})
      UserService.send(:save_users, {})
    end
  end

  context 'enable_user' do
    it 'should set enabled flag on user' do
      users = [ User.new(:id => 123, :name => 'name123', :image_url => 'url123', :enabled => false) ]
      UserService.stubs(:get_users).returns users
      UserService.stubs(:save_users)
      UserService.enable_user 123
      users[0].enabled?.should eq(true)
    end

    it 'should not save changes if user does not exist' do
      UserService.stubs(:get_users).returns []
      UserService.should_not_receive :save_users
      UserService.enable_user 123
    end
  end

  context 'disable_user' do
    it 'should set enabled flag on user' do
      users = [ User.new(:id => 123, :name => 'name123', :image_url => 'url123', :enabled => true) ]
      UserService.stubs(:get_users).returns users
      UserService.stubs(:save_users)
      UserService.disable_user 123
      users[0].enabled?.should eq(false)
    end

    it 'should not save changes if user does not exist' do
      UserService.stubs(:get_users).returns []
      UserService.should_not_receive :save_users
      UserService.disable_user 123
    end
  end
end
