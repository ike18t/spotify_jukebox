require_relative '../spec_helper'

describe MusicService do
  it 'should call the corresponding method in the spotify_wrapper' do
    [:playing?, :skip!, :stop!, :play!].each do |method_name|
      wrapper_double = double
      expect(wrapper_double).to receive(method_name)
      expect(MusicService).to receive(:spotify_wrapper).and_return(wrapper_double)
      MusicService.send method_name
    end
  end

  context 'play' do
    it 'should call play_track on wrapper with the spotify_track' do
      track_double = double({:spotify_track => ''})
      wrapper_double = double
      expect(MusicService).to receive(:spotify_wrapper).and_return(wrapper_double)
      expect(wrapper_double).to receive(:play_track).with(track_double.spotify_track)
      MusicService.play track_double
    end
  end
end
