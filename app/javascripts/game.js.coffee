#= require connection
#= require logger
class Game
  constructor: ->
    @spriteSize = 48
    @playerSpeed = 3
    @canvasCols = 15
    @canvasRows = 11
    @canvasSizeX = @spriteSize * @canvasCols
    @canvasSizeY = @spriteSize * @canvasRows
    @gameObjects = {}
    @players = {}
    @myPlayerId = null
    @conn = null
    @logger = new Logger document.getElementById("sidebar")

    # start crafty
    Crafty.init @canvasSizeX, @canvasSizeY
    Crafty.canvas.init()

    # turn the sprite map into usable components
    Crafty.sprite @spriteSize, "images/sprite.png",
      floor1: [0,0]
      floor2: [1,0]
      floor3: [2,0]
      floor4: [3,0]
      floor5: [4,0]
      floor6: [5,0]
      bomb: [0,1]
      bombup: [3,1]
      radiusup: [4,1]
      explosion: [0,2]
      player1: [0,3]
      player2: [0,4]
      player3: [0,5]
      player4: [0,6]
      player5: [0,7]
      wall: [9,2]
      metal: [10,2]
      box: [11,2]

  start: ->
    @preloader()

  connectServer: ->
    @conn = new Connection
      onOpen: @resetGame
      onMessage: @dispatchServerMessage

  joinGame: =>
    console.log "joining game"
    @conn.sendMessage
      type: "join"

  # the loading screen that will display while our assets load
  preloader: ->
    self = @
    Crafty.scene "loading", ->
      # load takes an array of assets and a callback when complete
      Crafty.load ["images/sprite.png"], ->
        self.buildMainScene() # when everything is loaded, run the main scene

      # black background with some loading text
      Crafty.background "#000"
      (Crafty.e "2D, DOM, Image")
        .attr(
          w: 604
          h: 352
          x: (self.canvasSizeX/2) - (604/2)
          y: (self.canvasSizeY/2) - (352/2)
        )
        .image "images/loading.png"

    # automatically play the loading scene
    Crafty.scene("loading")

  buildMainScene: ->
    self = @
    Crafty.scene "main", ->
      console.log "generating world"
      self.buildWorld()
      for player_number in [1..5]
        self.buildHero(player_number)
        self.buildOtherHero(player_number)
      self.buildControls()
      # trigger these in callbacks:
      #self.loadMap()
      #self.buildPlayer()

    # draw scene
    Crafty.scene("main")
    @connectServer()

  # method to randomly generate the map
  buildWorld: ->
    self = @
    # generate the grass along the x-axis
    for i in [0..@canvasCols-1]
      # generate the grass along the y-axis
      for j in [0..@canvasRows-1]
        floorType = Crafty.math.randomInt 1, 6
        (Crafty.e "2D, Canvas, floor#{floorType}")
          .attr
            x: i * @spriteSize
            y: j * @spriteSize

  buildHero: (player_number) ->
    self = @
    Crafty.c "Hero#{player_number}",
      init: ->
        # setup animations
        @requires("SpriteAnimation, Collision")
          .animate("walk_left",  6, 2 + player_number, 8)
          .animate("walk_right", 9, 2 + player_number, 11)
          .animate("walk_up",    3, 2 + player_number, 5)
          .animate("walk_down",  0, 2 + player_number, 2)
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
          .bind('Moved', (from) ->
            maxX = self.canvasSizeX - self.spriteSize
            maxY = self.canvasSizeY - self.spriteSize
            validX = @_x < 0 || @_x > maxX
            validY = @_y < 0 || @_y > maxY
            #hits = @hit('solid')
            #console.log hits
            if false #hits || validX || validY
              @attr
                x: from.x
                y: from.y
            else
              dir = "left" if @_x < from.x
              dir = "right" if @_x > from.x
              dir = "up" if @_y < from.y
              dir = "down" if @_y > from.y
              # console.log "direction: #{dir}"

              # send to server
              self.conn.sendMessage
                type: "move"
                direction: dir
          )
          this

  buildOtherHero: (player_number) ->
    self = @
    Crafty.c "OtherHero#{player_number}",
      init: ->
        # setup animations
        @requires("SpriteAnimation, Collision")
          .animate("walk_left",  6, 2 + player_number, 8)
          .animate("walk_right", 9, 2 + player_number, 11)
          .animate("walk_up",    3, 2 + player_number, 5)
          .animate("walk_down",  0, 2 + player_number, 2)
        this

  buildControls: ->
    self = @
    Crafty.c "RightControls",
      init: ->
        @requires('Fourway')

      rightControls: (speed) ->
        #this.multiway(speed, {UP_ARROW: -90, DOWN_ARROW: 90, RIGHT_ARROW: 0, LEFT_ARROW: 180})
        @fourway speed
        this

  buildPlayer: (player_number) ->
    self = @
    num = player_number % 5
    # create our player entity with some premade components
    @player = (Crafty.e "2D, Canvas, player#{num}, RightControls, Hero#{num}, Animate, Collision, KeyBoard")
      .attr(
        x: 0
        y: 0
        z: 10
      )
      .rightControls(self.playerSpeed)
      .bind "KeyDown", (event) ->
        if event.key == Crafty.keys['SPACE']
          self.conn.sendMessage({ type: "place_bomb" })
    @player.attr("player_number", num)

  loadMap: ->
    console.log "requesting map"
    @conn.sendMessage type: "load_map"

  dispatchServerMessage: (event) =>
    # console.log "dispatchServerMessage"
    # console.log event
    # console.log this

    # console.log "message received:"
    # console.log event.data

    messages = JSON.parse event.data

    for message in messages
      # console.log message

      unless @myPlayerId # waiting for player id
        switch message.type
          when "my_player_id" then @initMyPlayerId         message
          when "reset"        then @processResetMessage    message
          #else console.log "no player id yet, ignore #{message.type} message"
      else
        switch message.type
          when "position"     then @processPositionMessage message
          when "delete"       then @processDeleteMessage   message
          when "reset"        then @processResetMessage    message
          when "score"        then @processScoreMessage    message
          when "game_end"     then @processGameEndMessage  message
          else
            console.log "unknown message type #{message.type}"
            console.log message

  initMyPlayerId: (message) ->
    # assign own player id
    @myPlayerId = message.player_id
    console.log "got player id: #{@myPlayerId}"
    # ready to request map
    @loadMap()

  processPositionMessage: (message) ->
    switch message.object_type
      when "block" # place a block (destroyable)
        @gameObjects[(String) message.id] = (Crafty.e "2D, DOM, box, solid").attr
          x: message.coordinates[0] * @spriteSize
          y: message.coordinates[1] * @spriteSize

      when "radiusup" # powerup: radius+1
        @gameObjects[(String) message.id] = (Crafty.e "2D, DOM, radiusup, solid").attr
          x: message.coordinates[0] * @spriteSize
          y: message.coordinates[1] * @spriteSize

      when "bombup" # powerup: bombs+1
        @gameObjects[(String) message.id] = (Crafty.e "2D, DOM, bombup, solid").attr
          x: message.coordinates[0] * @spriteSize
          y: message.coordinates[1] * @spriteSize

      when "wall" # place a wall (undestroyable)
        @gameObjects[(String) message.id] = (Crafty.e "2D, DOM, wall, solid").attr
          x: message.coordinates[0] * @spriteSize
          y: message.coordinates[1] * @spriteSize

      when "explosion" # a bomb exploded
        @gameObjects[(String) message.id] = (Crafty.e "2D, DOM, explosion, SpriteAnimation")
          .animate("explode", 0, 2, 1)
          .bind("EnterFrame", ->
            unless @isPlaying()
              @animate("explode", 10, -1)
          ).attr(
            x: message.coordinates[0] * @spriteSize
            y: message.coordinates[1] * @spriteSize
            z: 50
          )

      when "bomb" # a bomb has been placed
        @gameObjects[(String) message.id] = (Crafty.e "2D, DOM, bomb, SpriteAnimation").attr(
            x: message.coordinates[0] * @spriteSize
            y: message.coordinates[1] * @spriteSize
            z: 30
          )
          .animate("pulsate", 0, 1, 2)
          .bind "EnterFrame", ->
            unless @isPlaying()
              @animate("pulsate", 60)

      when "player" # any player has moved
        # assign own player id to user on first movement =)
        if not @player && message.id == @myPlayerId
          console.log "creating player"
          @player = @buildPlayer message.player_number % 5
          @players[(String) message.id] = @player
          anyplayer = @player
          @logger.info "hero assigned"

        # create other players when they move
        if @players[(String) message.id] is undefined
          num = message.player_number % 5
          anyplayer = (Crafty.e "2D, Canvas, player#{num}, OtherHero#{num}, Animate, Collision")
          anyplayer.number = message.player_number
          @players[(String) message.id] = anyplayer
          @logger.info "player joined: " + message.id
        else
          anyplayer = @players[(String) message.id]

          if message.id != @myPlayerId
            if message.direction == "left"
              anyplayer.stop().animate("walk_left", 10, 0) unless anyplayer.isPlaying("walk_left")
            else if message.direction == "right"
              anyplayer.stop().animate("walk_right", 10, 0) unless anyplayer.isPlaying("walk_right")
            else if message.direction == "up"
              anyplayer.stop().animate("walk_up", 10, 0) unless anyplayer.isPlaying("walk_up")
            else if message.direction == "down"
              anyplayer.stop().animate("walk_down", 10, 0) unless anyplayer.isPlaying("walk_down")
            # anyplayer.stop()

        anyplayer.attr
          x: message.coordinates[0] * @spriteSize
          y: message.coordinates[1] * @spriteSize

  processDeleteMessage: (message) ->
    switch message.object_type
      when "player" # someone dies
        #console.log "delete player: " + message.id
        @players[(String) message.id]?.destroy()
        #delete @players[(String) message.id] # keep for scores
        @logger.info message.id + " died"

      else # some entity should be removed
        #console.log "delete entity: " + message.id
        @gameObjects[(String) message.id]?.destroy()
        delete @gameObjects[(String) message.id]

  processResetMessage: (message) ->
    console.log "received reset, destroying all players and objects"
    @resetGame()

  processScoreMessage: (message) ->
    @logger.info "#{message.player_id} nickname: #{message.nickname} score: #{message.score}"
    @players[message.player_id]?.score = message.score

  processGameEndMessage: (message) ->
    @logger.info "game ended, scoreboard:"
    for id, player of @players
      @logger.info "player #{player.number} score: #{player.score}"

  resetGame: =>
    console.log "resetting game"
    # delete players
    for id, player of @players
      player.destroy()
    @players = {}
    # delete objects
    for id, gameObject of @gameObjects
      gameObject.destroy()
    @gameObjects = {}
    @resetPlayer()

  resetPlayer: ->
    @player = null
    @myPlayerId = null
    @joinGame()

window.Game = Game

