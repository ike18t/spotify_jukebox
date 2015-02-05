var currentTrackWebSocket = function() {
  var updateTrackInfo = function(data) {
    var image_url = 'https://d3rt1990lpmkn.cloudfront.net/640/' + data.image;
    var $container = $('#track-data');
    $container.find('#art').css('background-image', 'url(' + image_url + ')');
    $container.find('#artist').text(data.artists);
    $container.find('#title').text(data.name);
    $container.find('#user-data').find('#name').text("Brought to you by " + data.user.name);
  };

  var updateEnabled = function(selector, data) {
    $(selector).each(function(idx, item) {
      $(item).toggleClass('disabled', data.indexOf(item.id) === -1);
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

  var bindPlayerControls = function() {
    $('#play-toggle').on('click', function() {
      var playing = $(this).hasClass('fa-pause');
      var action = playing? 'pause' : 'play';
      $.get(action);
    });

    $('#skip-button').on('click', function() {
      $.get('skip');
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
        updateEnabled('li.user', json_message.enabled_users);
      }
      if (json_message.hasOwnProperty('enabled_playlists')) {
        updateEnabled('li.playlist', json_message.enabled_playlists);
      }
      if (json_message.hasOwnProperty('play_status')) {
        updatePlayStatus(json_message.play_status);
      }
    };
    bindPlayerControls();
  };

  return this;
};
