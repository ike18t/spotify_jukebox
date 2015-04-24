angular.module('spotifyJukeboxApplication')
  .controller 'NowPlayingController', ['$scope', '$http', 'webSocketService', ($scope, $http, webSocketService) ->
    $scope.currentTrack = {}
    $scope.currentUser = {}
    $scope.isPlaying = false

    webSocketService.registerListener('current_track', (trackInfo) ->
      $scope.currentTrack = trackInfo
      $scope.$apply()
    )

    webSocketService.registerListener('current_user', (userInfo) ->
      $scope.currentUser = userInfo
      $scope.$apply()
    )

    webSocketService.registerListener('play_status', (playStatus) ->
      if playStatus.timestamp > (@lastPlayStatusTimeUpdate || 0)
        @lastPlayStatusTimeUpdate = playStatus.timestamp
        $scope.isPlaying = playStatus.playing
        $scope.$apply()
    )

    $scope.skip = ->
      $http.get('skip')
  ]
