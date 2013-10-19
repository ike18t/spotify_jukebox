#!/bin/sh
nohup bundle exec rake start > spotify_jukebox.log 2>&1 &
nohup app/spotify_player.rb > spotify_player.log 2>&1 &
