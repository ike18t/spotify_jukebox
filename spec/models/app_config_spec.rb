require_relative '../spec_helper'

describe AppConfig do
  it 'should update attributes with the values passed into initialize' do
    username = 'ike'
    playlist_uri = 'http://bah'
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
end
