# To use with thin
# thin start -p PORT -R config.ru

require File.join(File.dirname(__FILE__), 'app', 'spotify_jukebox.rb')

disable :run
set :environment, :production
run SpotifyJukebox
