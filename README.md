[![Build Status](https://travis-ci.org/ike18t/spotify_jukebox.png?branch=master)](https://travis-ci.org/ike18t/spotify_jukebox)
Spotify Jukebox
===============
**A collaborative jukebox solution**


**Setup**

Use the configure script located in the application's root directory to setup username, password, [Spotify application key](https://developer.spotify.com/technologies/libspotify/#application-keys) file path, and the collaborative playlist URI.
**WARNING: A Spotify premium account is required!**

**Usage**

```bundle exec rake start```

Once started the player will begin and a web server will be available on port 4567 which can be used to enable and disable collaborators on the playlist.


**This application is dependent on the openal library.**

**YUM:**
```
sudo yum install openal-soft-devel-1.12.854-1.el6.x86_64
```

**APT:**
```
sudo apt-get install libopenal-dev
```

**HOMEBREW:** 
```
brew install freealut
```
