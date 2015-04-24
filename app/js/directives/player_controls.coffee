angular.module('spotifyJukeboxApplication')
  .directive('playerControls', ['$http', ($http) ->
    scope: {
      isPlaying: '='
    },
    link: ($scope, $element, $attributes) ->
      $scope.$watch('isPlaying', (isPlaying) ->
        $element.removeClass('fa-play, fa-pause')
        $element.off('click')
        if isPlaying
          $element.addClass('fa-pause')
          $element.on('click', ->
            $http.get('pause')
          )
        else
          $element.addClass('fa-play')
          $element.on('click', (event) ->
            $http.get('play')
          )
      )
  ])
