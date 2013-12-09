var currentTrackPoller = function() {
  var updateTrackInfo = function(data) {
    var url = 'https://d3rt1990lpmkn.cloudfront.net/cover/' + data.image;
    var art_image = $('<img id="album_art">').attr('src', url);
    $('#art').html(art_image);
    $('#artist').text(data.artists);
    $('#title').text(data.name);
    $('#added_by').text(data.adder);
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
