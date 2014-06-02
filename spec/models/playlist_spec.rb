require_relative '../spec_helper'

describe Playlist do
  context 'enabled?' do
    it { expect(Playlist.new({:enabled => true}).enabled?).to be true }

    it { expect(Playlist.new().enabled?).to be false }

    it { expect(Playlist.new({ :enabled => false }).enabled?).to be false }
  end
end
