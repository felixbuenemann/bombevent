class Connection
  constructor: ->
    serverUri = "ws://" + document.location.host.replace(/:3000/, ':3001') + '/'
    console.log("init server: " + serverUri)
    # connect socket
    @socket = new WebSocket(serverUri)
    @socket.onopen = @onOpen
    @socket.onclose = @onClose
    @socket.onmessage = @onMessage
    @socket.onerror = @onError

  onOpen: (event) ->
    console.log "connection opened"

  onClose: (event) ->
    console.log "connection closed"

  onMessage: (event) ->
    console.log "message received:"
    console.log event

  onError: (event) ->
    console.log("connection error:")
    console.log(event)

  sendMessage: (message) ->
    message = JSON.stringify [message]
    console.log message
    @socket.send message

class Game
  constructor: ->
    @spriteSize = 48
    @playerSpeed = 3
    @canvasCols = 15
    @canvasRows = 11
    @canvasSizeX = @spriteSize * @canvasCols
    @canvasSizeY = @spriteSize * @canvasRows
    # connect server
    @conn = new Connection

    # start crafty
    Crafty.init @canvasSizeX, @canvasSizeY
    Crafty.canvas.init()

    # turn the sprite map into usable components
    Crafty.sprite @spriteSize, "images/sprite.png",
      grass1: [0,0]
      grass2: [1,0]
      grass3: [2,0]
      grass4: [3,0]
      flower: [0,1]
      bush1:  [0,2]
      bush2:  [1,2]
      player: [0,3]

  start: ->
    @preloader()

  # the loading screen that will display while our assets load
  preloader: ->
    self = @
    Crafty.scene "loading", ->
      # load takes an array of assets and a callback when complete
      Crafty.load ["images/sprite.png"], ->
        console.log "building scene"
        self.buildMainScene() # when everything is loaded, run the main scene

      # black background with some loading text
      Crafty.background "#000"
      (Crafty.e "2D, DOM, Text")
        .attr(
          w: 100
          h: 20
          x: (self.canvasSizeX/2) - (100/2)
          y: (self.canvasSizeY/2) - (20/2)
        )
        .text("Loading")
        .css("text-align": "center")

    # automatically play the loading scene
    Crafty.scene("loading")

  buildMainScene: ->
    self = @
    Crafty.scene "main", ->
      console.log "generating world"
      self.generateWorld()

      Crafty.c 'Hero',
        init: ->
          # setup animations
          @requires("SpriteAnimation, Collision")
            .animate("walk_left", 6, 3, 8)
            .animate("walk_right", 9, 3, 11)
            .animate("walk_up", 3, 3, 5)
            .animate("walk_down", 0, 3, 2)
            # change direction when a direction change event is received
            .bind("NewDirection", (direction) ->
                if direction.x < 0
                  @stop().animate("walk_left", 10, -1) unless @isPlaying("walk_left")
                if direction.x > 0
                  @stop().animate("walk_right", 10, -1) unless @isPlaying("walk_right")
                if direction.y < 0
                  @stop().animate("walk_up", 10, -1) unless @isPlaying("walk_up")
                if direction.y > 0
                  @stop().animate("walk_down", 10, -1) unless @isPlaying("walk_down")
                if !direction.x && !direction.y
                  @stop()
            )
            # A rudimentary way to prevent the user from passing solid areas
            # or out of boundary
            .bind 'Moved', (from) ->
              maxX = self.canvasSizeX - self.spriteSize
              maxY = self.canvasSizeY - self.spriteSize
              validX = @_x < 0 || @_x > maxX
              validY = @_y < 0 || @_y > maxY
              if @hit('solid') || validX || validY
                @attr
                  x: from.x
                  y: from.y
              else
                dir = "left" if @_x < from.x
                dir = "right" if @_x > from.x
                dir = "up" if @_y < from.y
                dir = "down" if @_y > from.y
                console.log "direction: #{dir}"
                # send to server
                self.conn.sendMessage
                  type: "move"
                  direction: dir
          this

      Crafty.c "RightControls",
        init: ->
          @requires('Fourway')

        rightControls: (speed) ->
          #this.multiway(speed, {UP_ARROW: -90, DOWN_ARROW: 90, RIGHT_ARROW: 0, LEFT_ARROW: 180})
          @fourway speed
          this

      # create our player entity with some premade components
      player = (Crafty.e "2D, Canvas, player, RightControls, Hero, Animate, Collision")
        .attr(
          x: 160
          y: 144
          z: 1
        )
        .rightControls(self.playerSpeed)

    # draw scene
    Crafty.scene("main")

  # method to randomly generate the map
  generateWorld: ->
    # generate the grass along the x-axis
    for i in [0..@canvasCols-1]
      # generate the grass along the y-axis
      for j in [0..@canvasRows-1]
        grassType = Crafty.math.randomInt 1, 4
        (Crafty.e "2D, Canvas, grass#{grassType}")
          .attr
            x: i * @spriteSize
            y: j * @spriteSize

        if i > 0 && i < (@canvasCols-2) && j > 0 && j < (@canvasRows-2) && Crafty.math.randomInt(0, 50) > 49
          (Crafty.e "2D, DOM, flower, solid, SpriteAnimation")
            .attr(
              x: i * @spriteSize
              y: j * @spriteSize
            )
            .animate("wind", 0, 1, 3)
            .bind "EnterFrame", ->
              unless @isPlaying()
                @animate "wind", 80

      # create the bushes along the x-axis which will form the boundaries
      (Crafty.e "2D, Canvas, wall_top, solid, bush#{Crafty.math.randomInt 1, 2}")
        .attr
          x: i * @spriteSize
          y: 0
          z: 2
      (Crafty.e "2D, DOM, wall_bottom, solid, bush#{Crafty.math.randomInt 1, 2}")
        .attr
          x: i * @spriteSize
          y: @canvasSizeY - @spriteSize
          z: 2

    # create the bushes along the y-axis
    # we need to start one more and one less to not overlap the previous bushes
    for i in [1..@canvasRows-2]
      (Crafty.e "2D, DOM, wall_left, solid, bush#{Crafty.math.randomInt 1, 2}")
        .attr
          x: 0
          y: i * @spriteSize
          z: 2
      (Crafty.e "2D, Canvas, wall_right, solid, bush#{Crafty.math.randomInt 1, 2}")
        .attr
          x: @canvasSizeX - @spriteSize
          y: i * @spriteSize
          z: 2

window.onload = ->
  game = new Game
  game.start()

