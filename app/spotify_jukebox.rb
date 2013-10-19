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

	get '/whatbeplayin' do
		headers 'Access-Control-Allow-Origin'					=> '*',
						'Access-Conformation-Request-Method'	=> '*'
		content_type 'application/json'
    $metadata.to_json
	end

	def get_user_list
		link = Spotify.link_create_from_string 'spotify:user:1215286433:playlist:0Ur8JSOQMuu3HWj4G63S42'
		playlist = Spotify.playlist_create $session_wrapper.session, link
    poll($session_wrapper.session) { Spotify.playlist_is_loaded(playlist) }
		(0..Spotify.playlist_num_tracks(playlist)-1).map{|index|
			creator = Spotify.playlist_track_creator(playlist, index)
			Spotify.user_canonical_name creator
		}.uniq.sort
	end

	get '/' do
		@user_mapping = CacheHandler.get_user_mappings
		@current_track = $metadata

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
