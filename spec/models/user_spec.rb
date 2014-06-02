require_relative '../spec_helper'

describe User do
  context 'enabled?' do
    it { expect(User.new({:enabled => true}).enabled?).to be true }

    it { expect(User.new().enabled?).to be false }

    it { expect(User.new({ :enabled => false }).enabled?).to be false }
  end
end
