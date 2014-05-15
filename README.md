[![Build Status](https://travis-ci.org/ike18t/spotify_jukebox.png?branch=master)](https://travis-ci.org/ike18t/spotify_jukebox)
[![Code Climate](https://codeclimate.com/github/ike18t/spotify_jukebox.png)](https://codeclimate.com/github/ike18t/spotify_jukebox)
[![Test Coverage](https://codeclimate.com/github/ike18t/spotify_jukebox/coverage.png)](https://codeclimate.com/github/ike18t/spotify_jukebox)
[![Dependency Status](https://gemnasium.com/ike18t/spotify_jukebox.png)](https://gemnasium.com/ike18t/spotify_jukebox)

##Spotify Jukebox

**A collaborative jukebox solution**

###Dependencies###
* Spotify premium account
* [Spotify application key](https://developer.spotify.com/technologies/libspotify/#application-keys)
* Spotify collaborative playlist URI
* OpenAL


###Setup###

Use the configure script located in the application's root directory.
######Options######
* username
* password
* app_key
* playlist_uri

######Example######


```
./configure --username=homer --password==doh1 --app_key=/path/to/app_key --playlist_uri=spotify:user:123456789:playlist:0Zr8DSONMuu3HWj4G63S42
```

###Usage###

```
bundle exec rake start
```

Once started, the player will begin and a web server will be available on port 4567.  Once the web server is running the web interface can be used to enable and disable collaborators on the playlist as well as show the current track information.

###Installing OpenAL###

**YUM**

```
sudo yum install openal-soft-devel-1.12.854-1.el6.x86_64
```

**APT**

```
sudo apt-get install libopenal-dev
```

**HOMEBREW**

```
brew install freealut
```
