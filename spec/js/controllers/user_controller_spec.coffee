describe 'User Controller', ->
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

  describe '$scope.toggleEnabledUser', ->
    it 'should call the disable_user endpoint if the user is enabled', ->
      scope = {}
      @controller('UserController', { $scope: scope })
      ajaxSpy = spyOn(@http, 'put')
      scope.toggleEnabledUser({id: 1, enabled: true})
      expect(ajaxSpy).toHaveBeenCalledWith('users/1/disable')

    it 'should call the enable_user endpoint if the user is disabled', ->
      scope = {}
      @controller('UserController', { $scope: scope })
      ajaxSpy = spyOn(@http, 'put')
      scope.toggleEnabledUser({id: 1, enabled: false})
      expect(ajaxSpy).toHaveBeenCalledWith('users/1/enable')
