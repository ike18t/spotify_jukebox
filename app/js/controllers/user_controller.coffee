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
    )

    webSocketService.registerListener('playlists', (playlistData) ->
      $scope.playlists = playlistData
    )

    $scope.toggleEnabledUser = (user) ->
      action = if user.enabled then 'disable_user' else 'enable_user'
      $http.put("#{action}/#{user.id}")

    $scope.toggleEnabledPlaylist = (playlist) ->
      action = if playlist.enabled then 'disable_playlist' else 'enable_playlist'
      $http.put("#{action}/#{playlist.id}")
  ]
