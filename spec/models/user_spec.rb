require_relative '../spec_helper'

describe User do
  context 'enabled?' do
    it { User.new({:enabled => true}).enabled?.should be_true }

    it { User.new().enabled?.should be_false }

    it { User.new({ :enabled => false }).enabled?.should be_false }
  end
end
