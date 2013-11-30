require 'sinatra'
require 'sinatra-websocket'
require 'sinatra/assetpack'

class JukeboxWeb < Sinatra::Base
  require 'json'
  require 'spotify'
  require 'haml'
  require_relative 'spotify_scraper'

  register Sinatra::AssetPack
  set :root, File.join(File.dirname(__FILE__), '..')
  set :bind, '0.0.0.0'
  set :sockets, []

  assets do
    js :application, ['/js/*.js']
    css :application, ['/css/*.css']
  end

  def initialize
    super
    @@queue = settings.custom[:queue]
    @@session_wrapper = settings.custom[:session_wrapper]
    @@playlist_uri = settings.custom[:playlist_uri]
  end

  @@queue, @@current_track = nil
  Thread.new do
    loop do
      if not @@queue.nil? and not @@queue[:web].empty?
        @@current_track = @@queue[:web].pop
        settings.sockets.each {|s| s.send(@@current_track.to_json.to_s) }
      end
      sleep 0.1
    end
  end

  get '/whatbeplayin' do
    if not request.websocket?
      headers 'Access-Control-Allow-Origin'         => '*',
              'Access-Conformation-Request-Method'  => '*'
      content_type 'application/json'
      current_track = @@current_track
      current_track[:adder] = translate_name current_track[:adder]
      current_track.to_json
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send @@current_track.to_json.to_s unless @@current_track.nil?
          settings.sockets << ws
        end
        ws.onclose do
          settings.sockets.delete ws
        end
      end
    end
  end

  get '/pause' do
    @@queue[:player].push(:pause)
  end

  get '/play' do
    @@queue[:player].push(:play)
  end

  def get_user_list
    @@user ||=  begin
                  link = Spotify.link_create_from_string @@playlist_uri
                  playlist = Spotify.playlist_create @@session_wrapper.session, link
                  @@session_wrapper.poll { Spotify.playlist_is_loaded(playlist) }
                  (0..Spotify.playlist_num_tracks(playlist)-1).map{|index|
                    creator = Spotify.playlist_track_creator(playlist, index)
                    Spotify.user_canonical_name creator
                  }.uniq.sort
                end
  end

  def uri_to_url uri
    uri = uri.gsub ':', '/'
    uri.gsub 'spotify', 'http://play.spotify.com'
  end

  def translate_name name
    user_mapping = CacheHandler.get_user_mappings
    user_mapping[name] || name
  end

  get '/' do
    @user_mapping = CacheHandler.get_user_mappings
    @playlist_url = uri_to_url @@playlist_uri

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
      CacheHandler.cache_enabled_users! enabled
    end
    redirect '/'
  end

  get '/disable/:name' do
    name = params[:name]
    enabled = CacheHandler.get_enabled_users
    if get_user_list.include? name and enabled.include? name
      enabled.delete name
      CacheHandler.cache_enabled_users! enabled
    end
    redirect '/'
  end

end
