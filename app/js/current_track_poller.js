var currentTrackPoller = function() {
  var updateTrackInfo = function(data) {
    var url = 'https://d3rt1990lpmkn.cloudfront.net/cover/' + data.image;
    var $art_image = $('<img id="album_art">').attr('src', url);
    var $container = $('#current_track_container');
    $container.find('#art').html($art_image);
    $container.find('#artist').text(data.artists);
    $container.find('#title').text(data.name);
    $container.find('#playlist').text(data.playlist);
  };

  var pollTrack = function() {
    $.getJSON('/whatbeplayin', {}, updateTrackInfo);
  };

  var intervalHandle = null;

  this.initialize = function(){
    pollTrack();
    intervalHandle = setInterval(pollTrack, 5000);
  };

  this.stop = function() {
    if (intervalHandle != null) {
      clearInterval(intervalHandle);
    }
  };

  return this;
};
