require 'sinatra'
require 'sinatra-websocket'
require 'sinatra/assetpack'
require 'json'
require 'haml'
require 'sass'
require 'coffee_script'

class JukeboxWeb < Sinatra::Base
  set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
  set :bind, '0.0.0.0'
  set :sockets, []

  configure do
    enable :logging
  end

  register Sinatra::AssetPack
  assets do
    serve '/vendor/js', from: 'vendor/assets/js'
    js :application, [
      '/vendor/**/*.js',
      '/js/spotify_jukebox.js',
      '/js/services/*.js',
      '/js/controllers/*.js',
      '/js/directives/*.js'
    ]
    css :application, ['/css/**/*.css']
  end

  @@currently_playing = nil
  post '/player_endpoint' do
    @@currently_playing = JSON.parse(params['now_playing']).merge({ play_status: { playing: true, timestamp: Time.now.to_i } })
    broadcast @@currently_playing
    return :ok
  end

  get '/websocket_connect' do
    return 'Websocket connection required' unless request.websocket?
    request.websocket do |ws|
      ws.onopen do
        ws.send(@@currently_playing.to_json) unless @@currently_playing.nil?
        settings.sockets << ws
      end
      ws.onclose do
        settings.sockets.delete ws
      end
    end
  end

  get '/whatbeplayin' do
    headers 'Access-Control-Allow-Origin'         => '*',
            'Access-Conformation-Request-Method'  => 'GET'
    content_type 'application/json'
    @@currently_playing.merge({ play_status: { playing: MusicService.playing?, timestamp: Time.now.to_i } }).to_json
  end

  put '/play' do
    MusicService.play!
    broadcast({ play_status: { playing: MusicService.playing?, timestamp: Time.now.to_i } })
  end

  put '/pause' do
    MusicService.stop!
    broadcast({ play_status: { playing: MusicService.playing?, timestamp: Time.now.to_i } })
  end

  put '/skip' do
    MusicService.skip!
  end

  get '/' do
    haml :index
  end

  get '/users' do
    UserService.get_users.map(&:to_hash).to_json
  end

  get '/playlists' do
    PlaylistService.get_playlists.map(&:to_hash).to_json
  end

  post '/playlists' do
    playlist_url = params[:playlist_url]
    playlist_info = WebHelper.get_playlist_id_and_user_id_from_url playlist_url
    playlist_uri = WebHelper.create_playlist_uri playlist_info[:playlist_id], playlist_info[:user_id]
    PlaylistService.create_playlist playlist_info[:playlist_id], playlist_info[:user_id], playlist_uri
    redirect '/'
  end

  delete '/playlists/:playlist_id' do
    playlist_id = params[:playlist_id]
    PlaylistService.remove_playlist playlist_id
  end

  delete '/users/:user_id' do
    user_id = params[:user_id]
    UserService.remove_user user_id
  end

  put '/playlists/:playlist_id/enable' do
    return broadcast_results { PlaylistService.enable_playlist params[:playlist_id] }
  end

  put '/playlists/:playlist_id/disable' do
    return broadcast_results { PlaylistService.disable_playlist params[:playlist_id] }
  end

  put '/users/:user_id/enable' do
    return broadcast_results { UserService.enable_user params[:user_id] }
  end

  put '/users/:user_id/disable' do
    return broadcast_results { UserService.disable_user params[:user_id] }
  end

  def broadcast_results(&block)
    block.call
    broadcast_enabled
    :ok
  end

  def broadcast_enabled
    users = UserService.get_users.map(&:to_hash)
    playlists = PlaylistService.get_playlists.map(&:to_hash)
    broadcast({ users: users, playlists: playlists })
  end

  def broadcast(hash)
    json_string = hash.to_json.to_s
    settings.sockets.each do |socket|
      socket.send json_string
    end
  end
end
