angular.module('spotifyJukeboxApplication')
  .directive('albumArtBackground', [ ->
    scope: {
      imageUrl: '='
    },
    link: ($scope, $element, $attributes) ->
      $scope.$watch('imageUrl', (url) ->
        $element.css('background-image', "url('#{url}')")
      )
  ])
