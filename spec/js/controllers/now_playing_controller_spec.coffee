describe 'Now Playing Controller', ->
  beforeEach angular.mock.module 'spotifyJukeboxApplication'

  beforeEach angular.mock.module ($provide) ->
    $provide.factory 'jukeboxSocket', ($websocket, $window) ->
      url = "ws://#{$window.location.host}/websocket_connect"
      $websocket.$new {
        url: url,
        mock: true
      }
    return

  beforeEach angular.mock.inject ($controller, $http) ->
    @controller = $controller
    @http = $http

  describe '$scope.skip', ->
    it 'should call the skip endpoint', ->
      scope = {}
      @controller('NowPlayingController', { $scope: scope })
      ajaxSpy = spyOn(@http, 'get')
      scope.skip()
      expect(ajaxSpy).toHaveBeenCalled()
