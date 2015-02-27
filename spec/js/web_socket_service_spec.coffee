describe 'Web socket service', ->
  beforeEach angular.mock.module 'spotifyJukeboxApplication'

  beforeEach angular.mock.module ($provide) ->
    $provide.factory 'jukeboxSocket', ($websocket, $window) ->
      url = "ws://#{$window.location.host}/websocket_connect"
      $websocket.$new {
        url: url, enqueue: true,
        mock: {
          fixtures: {
            test: {
              data: 'my data stuff here'
            }
          }
        }
      }
    return

  beforeEach angular.mock.inject (jukeboxSocket, webSocketService) ->
    @webSocketService = webSocketService
    @socket = jukeboxSocket

  describe 'registerListener', ->
    it 'should register the listener and fire the callback on message recieve', (done) ->
      spy = jasmine.createSpy().and.callFake => @socket.$close()

      @webSocketService.registerListener('data', spy)
      @socket.$emit('test')

      @socket.$on '$close', ->
        expect(spy).toHaveBeenCalledWith('my data stuff here')
        done()
