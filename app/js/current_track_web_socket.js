var currentTrackWebSocket = function() {
  var updateTrackInfo = function(data) {
    var url = 'https://d3rt1990lpmkn.cloudfront.net/640/' + data.image;
    var $art_image = $('<img />').attr('src', url);
    var $container = $('#track-data');
    $container.find('#art').html($art_image);
    $container.find('#artist').text(data.artists);
    $container.find('#title').text(data.name);
    $container.find('#user-data').find('#name').text("Brought to you by " + data.user.name);
  };

  var updateEnabledPlaylists = function(data) {
    $('li.playlist').each(function(idx, item) {
      var $item = $(item);
      data.indexOf(item.id) >= 0 ? $item.addClass('active', 500) : $item.removeClass('active', 500);
    });
  }

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
