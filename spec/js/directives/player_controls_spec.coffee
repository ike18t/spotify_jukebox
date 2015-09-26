describe 'Player Controls Directive', ->
  beforeEach angular.mock.module 'spotifyJukeboxApplication'

  template = '<player-controls data-is-playing="isPlaying"></player-controls>'
  beforeEach angular.mock.inject ($rootScope, $compile, $http) ->
    @scope = $rootScope.$new(true)
    @element = $compile(template)(@scope)
    @http = $http

  it 'should add pause class to element if playing', ->
    @scope.isPlaying = true
    @scope.$apply()
    expect(@element.hasClass('fa-play')).toBeFalsy()
    expect(@element.hasClass('fa-pause')).toBeTruthy()

  it 'should add play class to element if paused', ->
    @scope.isPlaying = false
    @scope.$apply()
    expect(@element.hasClass('fa-play')).toBeTruthy()
    expect(@element.hasClass('fa-pause')).toBeFalsy()

  it 'should hit pause endpoint if playing', ->
    @scope.isPlaying = true
    @scope.$apply()
    ajaxSpy = spyOn(@http, 'put')
    @element.triggerHandler('click')
    expect(ajaxSpy).toHaveBeenCalledWith('pause')

  it 'should hit play endpoint if paused', ->
    @scope.isPlaying = false
    @scope.$apply()
    ajaxSpy = spyOn(@http, 'put')
    @element.triggerHandler('click')
    expect(ajaxSpy).toHaveBeenCalledWith('play')
