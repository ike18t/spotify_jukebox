require_relative '../spec_helper'

describe AppConfig do
  it 'should update attributes with the values passed into initialize' do
    username = 'ike'
    config = AppConfig.new username: username
    expect(config.username).to eq(username)
  end

  it 'should IO read binary the app_key if the file exists' do
    app_key = '/path'
    config = AppConfig.new app_key: app_key
    expect(File).to receive(:exist?).and_return(true)
    expect(IO).to receive(:read)
    config.app_key
  end

  it 'should return nil for app_key if file does not exist' do
    app_key = '/path'
    config = AppConfig.new app_key: app_key
    expect(File).to receive(:exist?).and_return(false)
    expect(config.app_key).to be nil
  end

  it 'should have blank values if nothing passed in on intialization' do
    config = AppConfig.new
    expect(config.username).to be nil
    expect(config.password).to be nil
    expect(config.app_key).to be nil
  end

  it 'should accept an environment variable for the pw secret' do
    ClimateControl.modify(jukebox_secret: 'some_secret') do
      expect(AESCrypt).to receive(:encrypt).with('some_password', 'some_secret')
        .and_return('encrypted')
      expect(AESCrypt).to receive(:decrypt).with('encrypted', 'some_secret')
        .and_return('some_password')
      app_config = AppConfig.new
      app_config.password = 'some_password'
      expect(app_config.password).to eq 'some_password'
    end
  end
end
