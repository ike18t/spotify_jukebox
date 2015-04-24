angular.module('spotifyJukeboxApplication')
  .controller 'AddPlaylistController', ['$scope', '$http', ($scope, $http) ->
    $scope.show () =>
      ModalService.showModal
  ]
