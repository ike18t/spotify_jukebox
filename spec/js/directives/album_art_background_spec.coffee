describe 'Album Art Background Directive', ->
  beforeEach angular.mock.module 'spotifyJukeboxApplication'

  template = '<album-art-background image-url="imageUrl"></album-art-background>'
  beforeEach angular.mock.inject ($rootScope, $compile) ->
    @scope = $rootScope.$new(true)
    @scope.imageUrl = 'http://foo.com'
    @element = $compile(template)(@scope)

  it 'should update the elements background-image on scope imageUrl change', ->
    imageUrl = 'http://bar.com/'
    @scope.imageUrl = imageUrl
    @scope.$apply()
    expect(@element.css('background-image')).toEqual("url(#{imageUrl})")
