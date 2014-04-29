require 'sinatra'
require 'sinatra-websocket'
require 'sinatra/assetpack'
require 'json'
require 'haml'
require 'sass'
require_relative 'playlist'

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
    @@spotify_wrapper = settings.custom[:spotify_wrapper]
    @@playlist_uri = settings.custom[:playlist_uri]
  end

  @@message_queue, @@current_track = nil
  Thread.new do
    loop do
      if not @@message_queue.nil? and not @@message_queue.empty?
        @@current_track = @@message_queue.pop
        current_track = @@current_track.clone
        settings.sockets.each {|s| s.send({:current_track => current_track}.to_json.to_s) }
      end
      sleep 0.1
    end
  end

  get '/websocket_connect' do
    if not request.websocket? then return 'Websocket connection required' end
    current_track = @@current_track ? @@current_track.clone : nil
    request.websocket do |ws|
      ws.onopen do
        ws.send({ :current_track => current_track }.to_json.to_s) unless current_track.nil?
        settings.sockets << ws
      end
      ws.onclose do
        settings.sockets.delete ws
      end
    end
  end

  get '/whatbeplayin' do
    current_track = @@current_track.clone
    headers 'Access-Control-Allow-Origin'         => '*',
            'Access-Conformation-Request-Method'  => '*'
    content_type 'application/json'
    current_track.to_json
  end

  get '/pause' do
    @@spotify_wrapper.stop!
    redirect '/'
  end

  get '/play' do
    @@spotify_wrapper.play!
    redirect '/'
  end

  get '/skip' do
    @@spotify_wrapper.skip!
    redirect '/'
  end

  get '/' do
    playlists = CacheHandler.get_playlists
    haml :index, :locals => { :playlists => playlists, :playing => @@spotify_wrapper.playing? }
  end

  post '/add_playlist' do
    name = params[:name]
    url  = params[:url]
    playlist = Playlist.new :name => name, :url => url
    playlists = CacheHandler.get_playlists
    playlists << playlist
    CacheHandler.cache_playlists! playlists
    redirect '/'
  end

  post '/remove_playlist' do
    name = params[:name]
    playlists = CacheHandler.get_playlists
    playlists.reject!{ |p| p.name == name }
    CacheHandler.cache_playlists! playlists
    redirect '/'
  end

  post '/enable/:playlist_name' do
    playlist_name = params[:playlist_name]
    playlists = CacheHandler.get_playlists
    playlist_index = playlists.index { |playlist| playlist.name == playlist_name }
    return :error if playlist_index < 0
    playlists[playlist_index].enabled = true
    CacheHandler.cache_playlists! playlists
    broadcast_enabled playlists
    return :ok
  end

  post '/disable/:playlist_name' do
    playlist_name = params[:playlist_name]
    playlists = CacheHandler.get_playlists
    playlist_index = playlists.index { |playlist| playlist.name == playlist_name }
    return :error if playlist_index < 0
    playlists[playlist_index].enabled = false
    CacheHandler.cache_playlists! playlists
    broadcast_enabled playlists
    return :ok
  end

  def broadcast_enabled playlists
    settings.sockets.each { |s| s.send({ :enabled_playlists => playlists.select{ |p| p.enabled? }.map { |p| p.name } }.to_json.to_s) }
  end

end
