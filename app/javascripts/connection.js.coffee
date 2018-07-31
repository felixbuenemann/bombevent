class Connection
  constructor: (options = {}) ->
    @options = options
    @reconnectDelay = 2000
    @serverUri = "ws://" + document.location.host.replace(/:3000$/, ':3001') + '/'

    @initSocket()

  initSocket: =>
    console.log "connecting websocket: #{@serverUri}"
    @socket = new WebSocket(@serverUri)
    @socket.onopen = @options.onOpen ? @onOpen
    @socket.onclose = @options.onClose ? @onClose
    @socket.onmessage = @options.onMessage ? @onMessage
    @socket.onerror = @options.onError ? @onError

  onOpen: (event) ->
    console.log "connection opened"

  onClose: (event) =>
    console.log "connection closed"
    # alert "connection to server lost"
    @tryReconnect()

  onMessage: (event) ->
    console.log "message received"
    #console.log event

  onError: (event) =>
    console.log("connection error")
    #console.log event
    @tryReconnect()

  sendMessage: (message) ->
    message = JSON.stringify [message]
    #console.log "sent message:"
    #console.log message
    @socket.send message

  tryReconnect: ->
    #alert "websocket connection lost trying to reconnect"
    console.log "server connection lost, trying to reconnect in #{(@reconnectDelay/1000).toFixed 1}s"
    setTimeout @initSocket, @reconnectDelay

window.Connection = Connection

