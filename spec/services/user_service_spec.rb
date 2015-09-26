require_relative '../spec_helper'

describe UserService do
  context 'create_user' do
    it 'should not add the user if it already exists' do
      allow(SpotifyScraper).to receive(:name_and_image_from_spotify_id).once
      existing = [User.new(id: 123)]
      allow(UserService).to receive(:get_users).once.and_return(existing)
      expect(UserService).to receive(:save_users).never
      UserService.create_user 123
    end

    it 'should add new user object to user cache' do
      allow(SpotifyScraper).to receive(:name_and_image_from_spotify_id).and_return({})
      existing = [double(id: 123)]
      expect(UserService).to receive(:get_users).once.and_return(existing)
      expect(UserService).to receive(:save_users).once
      user = UserService.create_user 321
      existing.include? user
    end

    it 'should set the users name and image_url from the return value of the scraper' do
      allow(UserService).to receive(:get_users).and_return([])
      allow(UserService).to receive(:save_users).once
      expect(SpotifyScraper).to receive(:name_and_image_from_spotify_id).with(123).once.and_return(name: 'some_name', image_url: 'some_url')
      user = UserService.create_user 123
      expect(user.name).to eq('some_name')
      expect(user.image_url).to eq('some_url')
    end
  end

  context 'get_enabled_users' do
    it 'should get users' do
      expect(UserService).to receive(:get_users).once.and_return({})
      UserService.get_enabled_users
    end

    it 'should only return users that are enabled' do
      enabled =  [User.new(id: 321, name: 'name321', image_url: 'url321', enabled: true),
                  User.new(id: 567, name: 'name567', image_url: 'url567', enabled: true)]
      disabled = [User.new(id: 123, name: 'name123', image_url: 'url123', enabled: false)]

      expect(UserService).to receive(:get_users).and_return(enabled + disabled)
      expect(UserService.get_enabled_users).to eq(enabled)
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
      users = [User.new(id: 123, name: 'name123', image_url: 'url123', enabled: false)]
      expect(UserService).to receive(:get_users).and_return(users)
      expect(UserService).to receive(:save_users)
      UserService.enable_user 123
      expect(users[0].enabled?).to be true
    end

    it 'should not save changes if user does not exist' do
      allow(UserService).to receive(:get_users).and_return([])
      expect(UserService).to receive(:save_users).never
      UserService.enable_user 123
    end
  end

  context 'disable_user' do
    it 'should set enabled flag on user' do
      users = [User.new(id: 123, name: 'name123', image_url: 'url123', enabled: true)]
      allow(UserService).to receive(:get_users).and_return(users)
      allow(UserService).to receive(:save_users)
      UserService.disable_user 123
      expect(users[0].enabled?).to be false
    end

    it 'should not save changes if user does not exist' do
      allow(UserService).to receive(:get_users).and_return([])
      expect(UserService).to receive(:save_users).never
      UserService.disable_user 123
    end
  end

  context 'remove_user' do
    it 'should remove user form array and save' do
      users =  [User.new(id: 321),
                User.new(id: 123)]
      allow(UserService).to receive(:get_users).and_return(users)
      expect(UserService).to receive(:save_users).with([users[0]])
      UserService.remove_user(123)
    end

    it 'should remove users playlist form array and save' do
      users =  [User.new(id: 321),
                User.new(id: 123)]
      @playlists = [Playlist.new(id: 321, user_id: 123),
                    Playlist.new(id: 123, user_id: 123)]
      allow(UserService).to receive(:get_users).and_return(users)
      expect(PlaylistService).to receive(:get_playlists_for_user).with(123).and_return(@playlists)
      expect(UserService).to receive(:save_users).with([users[0]])
      UserService.remove_user(123)
      @playlists.count == 0
    end
  end
end
