require_relative '../spec_helper'

describe Playlist do
  context 'enabled?' do
    it { Playlist.new({:enabled => true}).enabled?.should be_true }

    it { Playlist.new().enabled?.should be_false }

    it { Playlist.new({ :enabled => false }).enabled?.should be_false }
  end
end
