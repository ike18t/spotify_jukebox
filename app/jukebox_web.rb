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
    css :application, ['/css/*.css']
  end

  def initialize
    super
    @@message_queue = settings.custom[:message_queue]
  end

  def get_playlist_id_and_user_id_from_url url
    match_data = url.match /^.*user\/(.*)\/playlist\/(.*)$/
    { :user_id => match_data[1], :playlist_id => match_data[2] }
  end

  def create_playlist_uri playlist_id, owner_id
    uri_format = 'spotify:user:%s:playlist:%s'
    uri_format % [owner_id, playlist_id]
  end

  @@message_queue, @@current_track = nil
  Thread.new do
    loop do
      if not @@message_queue.nil? and not @@message_queue.empty?
        @@current_track = @@message_queue.pop
        json = { :current_track => { :name => @@current_track.name,
                                     :artists => @@current_track.artists.join(', '),
                                     :album => @@current_track.album.name,
                                     :image => @@current_track.album.art_hex} }.to_json.to_s
        settings.sockets.each { |socket| socket.send(json) }
      end
      sleep 1
    end
  end

  get '/websocket_connect' do
    if not request.websocket? then return 'Websocket connection required' end
    request.websocket do |ws|
      ws.onopen do
        if not @@current_track.nil?
          json = { :current_track => { :name => @@current_track.name,
                                       :artists => @@current_track.artists.join(', '),
                                       :album => @@current_track.album.name,
                                       :image => @@current_track.album.art_hex} }.to_json.to_s
          ws.send(json)
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
    { :current_track => { :name => @@current_track.name,
                          :artists => @@current_track.artists.join(', '),
                          :album => @@current_track.album.name,
                          :image => @@current_track.album.art_hex} }.to_json.to_s
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
    haml :index, :locals => { :users => users, :playing => MusicService.playing? }
  end

  post '/add_playlist' do
    playlist_url = params[:playlist_url]
    playlist_info = get_playlist_id_and_user_id_from_url playlist_url
    playlist_uri = create_playlist_uri playlist_info[:playlist_id], playlist_info[:user_id]
    PlaylistService.create_playlist playlist_uri, playlist_info[:playlist_id], playlist_info[:user_id]
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
    return :ok
  end

  post '/disable_playlist/:playlist_id' do
    playlist_id = params[:playlist_id]
    PlaylistService.disable_playlist playlist_id
    return :ok
  end

  post '/enable_user/:id' do
    user_id = params[:id]
    UserService.enable_user user_id
    broadcast_enabled UserService.get_enabled_users
    return :ok
  end

  post '/disable_user/:id' do
    user_id = params[:id]
    UserService.disable_user user_id
    broadcast_enabled UserService.get_enabled_users
    return :ok
  end

  def broadcast_enabled users
    settings.sockets.each do |socket|
      enabled_user_ids = users.select{ |u| u.enabled? }.map{ |u| u.id }
      enabled_json = { :enabled_users => enabled_user_ids }.to_json.to_s
      socket.send enabled_json
    end
  end

end
