<h1>Spotify Jukebox</h1>
<h4>A collaborative jukebox solution</h4>
**WARNING: A Spotify premium account is required!**

Use the configure script located in the application's root directory to setup username, password, api_key location, and the collaborative playlist uri.

To start: <code>bundle exec rake start</code>

Once started the player will begin and a web server will be available on port 4567 which can be used to enable and disable collaborators on the playlist.


**This application is dependent on the openal library.**

**YUM:**
<code>sudo yum install openal-soft-devel-1.12.854-1.el6.x86_64</code>

**APT:**
<code>sudo apt-get install libopenal-dev</code>

**HOMEBREW:** Requires adding a mirror to download the gem.

<code>brew edit freealut</code>

<code>mirror 'http://ftp.de.debian.org/debian/pool/main/f/freealut/freealut_1.1.0.orig.tar.gz'</code>

<code>brew install freealut</code>
