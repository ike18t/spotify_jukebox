require 'sinatra/asset_pipeline'
require 'sinatra/jbuilder'

class JukeboxWeb < Sinatra::Base
  set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
  set :bind, '0.0.0.0'
  set :sockets, []
  set :sprockets, Sprockets::Environment.new(root)
  set :assets_paths, %w('frontend/dist' 'app/js' 'app/css')
  set :assets_css_compressor, :scss
  set :assets_paths, %w(frontend/dist app/js app/css)
  set :assets_precompile, 'application.js', 'js/style.scss'
  set :logging, true

  helpers do
    include Sprockets::Helpers
  end

  register Sinatra::AssetPipeline

  @@currently_playing = nil
  post '/player_endpoint' do
    @@currently_playing = JSON.parse(params['now_playing']).merge('play_status' => { 'playing' => true, 'timestamp' => Time.now.to_i })
    broadcast @@currently_playing.to_json
    :ok
  end

  @@currently_play = false
  post '/player_status_endpoint' do
    @@currently_play = JSON.parse(params['status'])['playing']
    @@currently_playing = (@@currently_playing || {}).merge({'play_status' => { 'playing' => @@currently_play, 'timestamp' => Time.now.to_i }})
    broadcast @@currently_playing.to_json
    :ok
  end

  get '/websocket_connect' do
    return 'Websocket connection required' unless request.websocket?
    request.websocket do |ws|
      ws.onopen do
        broadcast_enabled [ws]
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
    @@currently_playing.merge(play_status: { playing: true, timestamp: Time.now.to_i }).to_json
  end

  put '/play' do
    # broadcast(play_status: { playing: MusicService.playing?, timestamp: Time.now.to_i })
    do_the_thing :play
    :ok
  end

  put '/pause' do
    # broadcast(play_status: { playing: MusicService.playing?, timestamp: Time.now.to_i })
    do_the_thing :pause
    :ok
  end

  put '/skip' do
    do_the_thing :skip
    :ok
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
    playlist_uri = params[:playlist_uri]
    playlist_info = nil

    if playlist_url
      playlist_info = WebHelper.get_playlist_id_and_user_id_from_url playlist_url
      playlist_uri = WebHelper.create_playlist_uri playlist_info[:playlist_id], playlist_info[:user_id]
    else
      playlist_info = WebHelper.get_playlist_id_and_user_id_from_uri playlist_uri
    end

    PlaylistService.create_playlist playlist_info[:playlist_id], playlist_info[:user_id], playlist_uri
    redirect '/'
  end

  post '/users/:user_id/playlists' do
    user_id = params[:user_id]
    playlist_url = params[:playlist_url]
    playlist_uri = params[:playlist_uri]
    playlist_info = nil

    if playlist_url
      playlist_info = WebHelper.get_playlist_id_and_user_id_from_url playlist_url
      playlist_uri = WebHelper.create_playlist_uri playlist_info[:playlist_id], playlist_info[:user_id]
    else
      playlist_info = WebHelper.get_playlist_id_and_user_id_from_uri playlist_uri
    end
    PlaylistService.create_playlist playlist_info[:playlist_id], user_id, playlist_uri
    broadcast_enabled
    :ok
  end

  delete '/playlists/:playlist_id' do
    playlist_id = params[:playlist_id]
    PlaylistService.remove_playlist playlist_id
    :ok
  end

  delete '/users/:user_id' do
    user_id = params[:user_id]
    UserService.remove_user user_id
    :ok
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

  def broadcast_results
    yield
    broadcast_enabled
    :ok
  end

  def broadcast_enabled(sockets = settings.sockets)
    users = UserService.get_users
    playlists = PlaylistService.get_playlists
    json = jbuilder :users_and_playlists, locals: { users: users, playlists: playlists }
    broadcast(json, sockets)
  end

  def broadcast(value, sockets = settings.sockets)
    if value.class == Hash
      value = hash.to_json.to_s
    end
    sockets.each do |socket|
      socket.send value
    end
  end

  def do_the_thing command
    command_map = {
                    skip: 'USR1',
                    play: 'CONT',
                    pause: 'USR2'
                  }
    pid = File.read('tmp/pid').to_i
    puts command_map[command]
    Process.kill command_map[command], pid
  end
end
