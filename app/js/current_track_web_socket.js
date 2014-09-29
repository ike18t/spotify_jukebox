var currentTrackWebSocket = function() {
  var updateTrackInfo = function(data) {
    var image_url = 'https://d3rt1990lpmkn.cloudfront.net/640/' + data.image;
    var $container = $('#track-data');
    $container.find('#art').css('background-image', 'url(' + image_url + ')');
    $container.find('#artist').text(data.artists);
    $container.find('#title').text(data.name);
    $container.find('#user-data').find('#name').text("Brought to you by " + data.user.name);
  };

  var updateEnabledUsers = function(data) {
    $('.users li').each(function(idx, item) {
      var $item = $(item);
      data.indexOf(item.id) >= 0 ? $item.addClass('enabled', 500) : $item.removeClass('enabled', 500);
    });
  };

  var updateEnabledPlaylists = function(data) {
    $('li.playlist').each(function(idx, item) {
      var $item = $(item);
      data.indexOf(item.id) >= 0 ? $item.addClass('active', 500) : $item.removeClass('active', 500);
    });
  };

  var lastPlayStatusTimeUpdate;
  var updatePlayStatus = function(data) {
    if (lastPlayStatusTimeUpdate > data.timestamp) {
      return;
    }
    lastPlayStatusTimeUpdate = data.timestamp;
    var $playToggle = $('#play-toggle');
    $playToggle.removeClass('fa-play, fa-pause');
    if (data.playing) {
      $playToggle.addClass('fa-pause');
    } else {
      $playToggle.addClass('fa-play');
    }
  };

  var bindPlayToggle = function() {
    $('#play-toggle').on('click', function() {
      var playing = $(this).hasClass('fa-pause');
      var actionUrl = playing? 'pause' : 'play';
      $.ajax(actionUrl, { type: 'PUT' });
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
      if (json_message.hasOwnProperty('enabled_users')) {
        updateEnabledUsers(json_message.enabled_users);
      }
      if (json_message.hasOwnProperty('enabled_playlists')) {
        updateEnabledPlaylists(json_message.enabled_playlists);
      }
      if (json_message.hasOwnProperty('play_status')) {
        updatePlayStatus(json_message.play_status);
      }
    };
    bindPlayToggle();
  };

  return this;
};
