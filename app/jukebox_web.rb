require 'sinatra'
require 'sinatra-websocket'
require 'sinatra/assetpack'

class JukeboxWeb < Sinatra::Base
  require 'json'
  require 'spotify'
  require 'haml'
  require 'memoize'
  require_relative 'name_translator'

  extend Memoize

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
        current_track = @@current_track.clone
        current_track[:adder] = NameTranslator.get_for current_track[:adder]
        settings.sockets.each {|s| s.send(current_track.to_json.to_s) }
      end
      sleep 0.1
    end
  end

  get '/whatbeplayin' do
    current_track = @@current_track.clone
    current_track[:adder] = NameTranslator.get_for(@@current_track[:adder]) if not @@current_track.nil?
    if not request.websocket?
      headers 'Access-Control-Allow-Origin'         => '*',
              'Access-Conformation-Request-Method'  => '*'
      content_type 'application/json'
      current_track.to_json
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send current_track.to_json.to_s unless current_track.nil?
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

  get '/' do
    enabled_users = CacheHandler.get_enabled_users

    user_list = get_user_list
    user_list.map! do |user_name|
      display_name = NameTranslator.get_for user_name
      enabled_flag = enabled_users.include?(user_name)
      { :user_name => user_name, :display_name => display_name, :enabled_flag => enabled_flag }
    end
    haml :index, :locals => { :users => user_list, :playlist_url => get_playlist_url }
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

  def get_user_list
    link = Spotify.link_create_from_string @@playlist_uri
    playlist = Spotify.playlist_create @@session_wrapper.session, link
    @@session_wrapper.poll { Spotify.playlist_is_loaded(playlist) }
    (0..Spotify.playlist_num_tracks(playlist)-1).map{|index|
      creator = Spotify.playlist_track_creator(playlist, index)
      user = Spotify.user_canonical_name creator
      creator.free
      user
    }.uniq.sort
  end
  memoize :get_user_list

  def get_playlist_url
    uri = @@playlist_uri.gsub ':', '/'
    uri.gsub 'spotify', 'http://play.spotify.com'
  end
  memoize :get_playlist_url

end
