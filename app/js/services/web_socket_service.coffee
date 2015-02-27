angular.module('spotifyJukeboxApplication')
  .factory 'jukeboxSocket', ($websocket, $window) ->
    $websocket.$new "ws://#{$window.location.host}/websocket_connect"
  .service 'webSocketService', ['jukeboxSocket', '$window', (jukeboxSocket, $window) ->
    registrationLookup = {}

    establishConnection = ->
      jukeboxSocket.$on '$open', ->
        console.log 'websocket opened'
      jukeboxSocket.$on '$close', ->
        console.log 'websocket closed'
      jukeboxSocket.$on '$message', (data) ->
        json = JSON.parse(data)
        for messageType in Object.keys(json)
          for callback in registrationLookup[messageType] || []
            callback.call this, json[messageType]

    establishConnection()

    @registerListener = (messageType, callback) ->
      if registrationLookup[messageType] == undefined
        registrationLookup[messageType] = []
      registrationLookup[messageType].push callback

    return this
  ]
