require_relative '../spec_helper'

describe AppConfig do
  it 'should update attributes with the values passed into initialize' do
    username, playlist_uri = 'ike', 'http://bah'
    config = AppConfig.new :username => username
    config.username.should eq(username)
  end

  it 'should IO read binary the app_key if the file exists' do
    app_key = '/path'
    config = AppConfig.new :app_key => app_key
    File.stubs(:exists?).returns(true)
    IO.expects(:read)
    config.app_key
  end

  it 'should return nil for app_key if file does not exist' do
    app_key = '/path'
    config = AppConfig.new :app_key => app_key
    File.stubs(:exists?).returns(false)
    config.app_key.should be_nil
  end

  it 'should have blank values if nothing passed in on intialization' do
    config = AppConfig.new
    config.username.should be_nil
    config.password.should be_nil
    config.app_key.should be_nil
  end
end
