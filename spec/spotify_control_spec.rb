require 'spec_helper'

describe 'SpotifyControl' do

  it 'should load the index' do
    get '/'
    last_response.should.be.ok
  end
end
