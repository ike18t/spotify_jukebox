angular.module('spotifyJukeboxApplication')
  .controller 'UserController', ['$scope', '$http', 'webSocketService', ($scope, $http, webSocketService) ->
    $scope.users = []
    $scope.playlists = []

    $http.get('users').success (data) ->
      $scope.users = data

    $http.get('playlists').success (data) ->
      $scope.playlists = data

    webSocketService.registerListener('users', (userData) ->
      $scope.users = userData
      $scope.$apply()
    )

    webSocketService.registerListener('playlists', (playlistData) ->
      $scope.playlists = playlistData
      $scope.$apply()
    )

    $scope.toggleEnabledUser = (user) ->
      action = if user.enabled then 'disable' else 'enable'
      $http.put("users/#{user.id}/#{action}")

    $scope.toggleEnabledPlaylist = (playlist) ->
      action = if playlist.enabled then 'disable' else 'enable'
      $http.put("playlists/#{playlist.id}/#{action}")
  ]
