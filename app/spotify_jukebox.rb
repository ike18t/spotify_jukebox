#!/usr/bin/env ruby

require_relative 'common'
require_relative 'spotify_scraper'
require 'sinatra'
require 'json'
require 'spotify'
require 'haml'
require 'sinatra/assetpack'

class SpotifyJukebox < Sinatra::Base
	register Sinatra::AssetPack
	set :root, File.join(File.dirname(__FILE__), '..')
	set :bind, '0.0.0.0'

  assets do
		js :application, ['/js/*.js']
		css :application, ['/css/*.css']
	end

	#
	# Main work code.
	#

	# You can read about what these session configuration options do in the
	# libspotify documentation:
	# https://developer.spotify.com/technologies/libspotify/docs/12.1.45/structsp__session__config.html
	config = Spotify::SessionConfig.new({
		api_version: Spotify::API_VERSION.to_i,
		application_key: $appkey,
		cache_location: '../.spotify/',
		settings_location: '../.spotify/',
		tracefile: '../spotify_tracefile.txt',
		user_agent: 'spotify for ruby',
		callbacks: Spotify::SessionCallbacks.new($session_callbacks),
	})

	$logger.info 'Creating session.'
	FFI::MemoryPointer.new(Spotify::Session) do |ptr|
		Spotify.try(:session_create, config, ptr)
		$session = Spotify::Session.new(ptr.read_pointer)
	end

	$logger.info 'Created! Logging in.'
	Spotify.session_login($session, $username, $password, false, nil)

	$logger.info 'Log in requested. Waiting forever until logged in.'
	poll($session) { Spotify.session_connectionstate($session) == :logged_in }

	$logger.info "Logged in as #{Spotify.session_user_name($session)}."

	get '/whatbeplayin' do
		headers 'Access-Control-Allow-Origin'					=> '*',
						'Access-Conformation-Request-Method'	=> '*'
		content_type 'application/json'
    YAML.load_file('metadata.yml').to_json
	end

	def get_user_list
		link = Spotify.link_create_from_string 'spotify:user:1215286433:playlist:0Ur8JSOQMuu3HWj4G63S42'
		playlist = Spotify.playlist_create $session, link
    poll($session) { Spotify.playlist_is_loaded(playlist) }
		(0..Spotify.playlist_num_tracks(playlist)-1).map{|index|
			creator = Spotify.playlist_track_creator(playlist, index)
			Spotify.user_canonical_name creator
		}.uniq.sort
	end

	get '/' do
		@user_mapping = CacheHandler.get_user_mappings
		@current_track = YAML.load_file('metadata.yml')

		users = get_user_list
		enabled = CacheHandler.get_enabled_users
		@users_for_view = {}
    mapping_update = false
		users.each {|user|
			if not @user_mapping.keys.include? user
        $logger.info "pulling user #{user} display name"
				@user_mapping[user] = SpotifyScraper.name_from_spotify_id(user)
			end
			@users_for_view[user] = enabled.include?(user)
      mapping_update = true
		}
    if mapping_update
      CacheHandler.cache_user_mappings! @user_mapping
    end
		haml :index
	end

	get '/enable/:name' do
		name = params[:name]
    enabled = CacheHandler.get_enabled_users
		if get_user_list.include? name and not enabled.include? name
			enabled << name
			CacheHandler.cache_enabled! enabled
		end
		redirect '/'
	end

	get '/disable/:name' do
		name = params[:name]
    enabled = CacheHandler.get_enabled_users
		if get_user_list.include? name and enabled.include? name
			enabled.delete name
			CacheHandler.cache_enabled! enabled
		end
		redirect '/'
	end

end
