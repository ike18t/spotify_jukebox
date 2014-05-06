require_relative '../spec_helper'

describe ConfigService do
  before do
    allow(ConfigService).to receive(:save)
    allow(ConfigService).to receive(:read).and_return(AppConfig.new)
  end

  context 'update' do
    it 'should update config model with hash values passed to update' do
      updates = { :username => 'ike' }
      ConfigService.update updates
      config = ConfigService.get
      config.username.should eq(updates[:username])
    end

    it { expect { ConfigService.update({ :username1 => 'ike' }) }.to raise_error(NoMethodError) }
  end
end
