var currentTrackWebSocket = function() {
  var updateTrackInfo = function(data) {
    var url = 'https://d3rt1990lpmkn.cloudfront.net/cover/' + data.image;
    var $art_image = $('<img id="album_art">').attr('src', url);
    var $container = $('#current_track_container');
    $container.find('#art').html($art_image);
    $container.find('#artist').text(data.artists);
    $container.find('#title').text(data.name);
    $container.find('#playlist').text(data.playlist);
  };

  var updateEnabledPlaylists = function(data) {
    $('#playlists li').each(function(idx, item) {
      var $item = $(item);
      data.indexOf(item.id) >= 0 ? $item.addClass('enabled', 500) : $item.removeClass('enabled', 500);
    });
  };

  var webSocket;
  this.initialize = function(){
    webSocket = new WebSocket('ws://' + window.location.host + '/websocket_connect');
    webSocket.onopen    = function()  { console.log('websocket opened'); };
    webSocket.onclose   = function()  { console.log('websocket closed'); };
    webSocket.onmessage = function(m) {
      console.log('websocket message: ' +  m.data);
      var json_message = JSON.parse(m.data);
      if (json_message.hasOwnProperty('current_track')) {
        updateTrackInfo(json_message.current_track);
      }
      if (json_message.hasOwnProperty('enabled_playlists')) {
        updateEnabledPlaylists(json_message.enabled_playlists);
      }
    };
  };

  return this;
};
