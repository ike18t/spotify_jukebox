var currentTrackWebSocket = function() {
  var updateTrackInfo = function(data) {
    var url = 'https://d3rt1990lpmkn.cloudfront.net/cover/' + data.image;
    var art_image = $('<img id="album_art">').attr('src', url);
    $('#art').html(art_image);
    $('#artist').text(data.artists);
    $('#title').text(data.name);
    $('#added_by').text(data.adder);
  };

  var webSocket;
  this.initialize = function(){
    webSocket = new WebSocket('ws://' + window.location.host + '/whatbeplayin');
    webSocket.onopen    = function()  { console.log('websocket opened'); };
    webSocket.onclose   = function()  { console.log('websocket closed'); };
    webSocket.onmessage = function(m) {
      console.log('websocket message: ' +  m.data);
      updateTrackInfo(JSON.parse(m.data));
    };
  };

  return this;
};
