require 'sinatra'
require 'sinatra-websocket'
require 'sinatra/assetpack'
require 'json'
require 'haml'
require 'sass'

class JukeboxWeb < Sinatra::Base
  register Sinatra::AssetPack

  set :root, File.join(File.dirname(__FILE__), '..')
  set :bind, '0.0.0.0'
  set :sockets, []

  assets do
    js :application, ['/js/*.js']
    css :application, ['/css/normalize.css', '/css/style.css', '/css/extruding-button.css']
  end

  @@currently_playing = nil
  post '/player_endpoint' do
    @@currently_playing = params['player_info']
    broadcast_json @@currently_playing
    return :ok
  end

  get '/websocket_connect' do
    if not request.websocket? then return 'Websocket connection required' end
    request.websocket do |ws|
      ws.onopen do
        if not @@currently_playing.nil?
          ws.send(@@currently_playing)
        end
        settings.sockets << ws
      end
      ws.onclose do
        settings.sockets.delete ws
      end
    end
  end

  get '/whatbeplayin' do
    headers 'Access-Control-Allow-Origin'         => '*',
            'Access-Conformation-Request-Method'  => '*'
    content_type 'application/json'
    @@currently_playing
  end

  get '/pause' do
    MusicService.stop!
    redirect '/'
  end

  get '/play' do
    MusicService.play!
    redirect '/'
  end

  get '/skip' do
    MusicService.skip!
    redirect '/'
  end

  get '/' do
    users = UserService.get_users
    playlists = users.inject({}) { |hash, user| hash[user.id] = PlaylistService.get_playlists_for_user(user.id); hash }
    haml :index, :locals => { :users => users, :playlists => playlists, :playing => MusicService.playing? }
  end

  post '/add_playlist' do
    playlist_url = params[:playlist_url]
    playlist_info = WebHelper.get_playlist_id_and_user_id_from_url playlist_url
    playlist_uri = WebHelper.create_playlist_uri playlist_info[:playlist_id], playlist_info[:user_id]
    PlaylistService.create_playlist playlist_info[:playlist_id], playlist_info[:user_id], playlist_uri
    redirect '/'
  end

  post '/remove_playlist' do
    playlist_id = params[:id]
    PlaylistService.remove_playlist playlist_id
    redirect '/'
  end

  post '/enable_playlist/:playlist_id' do
    playlist_id = params[:playlist_id]
    PlaylistService.enable_playlist playlist_id
    broadcast_enabled
    return :ok
  end

  post '/disable_playlist/:playlist_id' do
    playlist_id = params[:playlist_id]
    PlaylistService.disable_playlist playlist_id
    broadcast_enabled
    return :ok
  end

  post '/remove_user' do
    user_id = params[:id]
    UserService.remove_user user_id
    redirect '/'
  end

  post '/enable_user/:id' do
    user_id = params[:id]
    UserService.enable_user user_id
    broadcast_enabled
    return :ok
  end

  post '/disable_user/:id' do
    user_id = params[:id]
    UserService.disable_user user_id
    broadcast_enabled
    return :ok
  end

  def broadcast_enabled
    enabled_user_ids = UserService.get_enabled_users.map{ |user| user.id }
    enabled_playlist_ids = PlaylistService.get_enabled_playlists.map{ |playlist| playlist.id }
    settings.sockets.each do |socket|
      broadcast_json({ :enabled_users => enabled_user_ids, :enabled_playlists => enabled_playlist_ids }.to_json)
    end
  end

  def broadcast_json json
    settings.sockets.each do |socket|
      socket.send json.to_s
    end
  end
end
