require 'spec_helper'

describe TrackHistorian do
  before do
    @track_historian = TrackHistorian.new
  end

  context 'update_enabled_users_list' do
    it 'should update enabled user list should do what its name implies' do
      dummy_list = [:a, :b]
      @track_historian.update_enabled_users_list dummy_list
      @track_historian.instance_variable_get(:@enabled_users).should eq(dummy_list)
    end
  end

  context 'update_user_track_count' do
    it 'should store the user count key value pair in the user_track_counts instance variable' do
      user, count = 'ike', 2
      @track_historian.update_user_track_count user, count
      @track_historian.instance_variable_get(:@user_track_counts).should eq({user => count})
    end
  end

  context 'record' do
    it 'should add track key to the array' do
      track_key = 'track_key'
      @track_historian.stubs(:generate_track_key).returns(track_key)
      @track_historian.stubs(:get_calculated_size).returns(1)
      @track_historian.record 'track_placeholder'
      @track_historian.instance_variable_get(:@track_history).should include(track_key)
    end

    it 'should bump value in index 0 if max size has been met' do
      track_key = 'track_key'
      @track_historian.instance_variable_set(:@track_history, [:a, :b, :c])
      @track_historian.stubs(:generate_track_key).returns(:d)
      @track_historian.stubs(:get_calculated_size).returns(3)
      @track_historian.record 'dummy_value'
      @track_historian.instance_variable_get(:@track_history).should eq([:b, :c, :d])
    end
  end

  context 'played_recently?' do
    it 'should return true if the track key is in the track_history array' do
      @track_historian.instance_variable_set(:@track_history, [:a, :b, :c])
      @track_historian.stubs(:generate_track_key).returns(:b)
      @track_historian.played_recently?('dummy_value').should be_true
    end

    it 'should return false if the track key is not in the track_history array' do
      @track_historian.instance_variable_set(:@track_history, [:a, :b, :c])
      @track_historian.stubs(:generate_track_key).returns(:d)
      @track_historian.played_recently?('dummy_value').should be_false
    end
  end

  context 'generate_track_key' do
    before do
      $session_wrapper = double.as_null_object
      Spotify.stubs(:track_name).returns('track_name')
      Spotify.stubs(:track_artist).returns(double(null?: false))
      Spotify.stubs(:artist_name).returns('artist_name')
    end

    it 'should generate a track key in the format artist_name => track_name' do
      @track_historian.send(:generate_track_key, 'track_placeholder').should eq('artist_name => track_name')
    end

    it 'should poll until the artist is not null' do
      Spotify.stubs(:null_artist).returns(double(null?: true))
      Spotify.stubs(:not_null_artist).returns(double(null?: false))

      class << @track_historian
        attr_reader :when_null, :when_not_null
        def poll(*args)
          Spotify.stubs(:track_artist).returns(Spotify.null_artist)
          @when_null = yield

          Spotify.stubs(:track_artist).returns(Spotify.not_null_artist)
          @when_not_null = yield
        end
      end

      @track_historian.send(:generate_track_key, 'foo')

      @track_historian.when_null.should be_false
      @track_historian.when_not_null.should be_true
    end
  end

  context 'get_calculated_size' do
    before do
      @track_historian.instance_variable_set(:@enabled_users, ['a', 'b', 'c'])
    end

    it { @track_historian.send(:get_calculated_size).should eq(0) }

    it 'should add enabled users track counts and half it' do
      user_track_counts = {'a' => 1, 'b' => 4, 'c' => 3}
      @track_historian.instance_variable_set(:@user_track_counts, user_track_counts)
      @track_historian.send(:get_calculated_size).should eq(4)
    end

    it 'should not error if an enabled_user is not in the list' do
      user_track_counts = {'a' => 1, 'c' => 3}
      @track_historian.instance_variable_set(:@user_track_counts, user_track_counts)
      @track_historian.send(:get_calculated_size).should eq(2)
    end
  end

end
