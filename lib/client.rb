require 'logging'
require 'player'
require 'game'
require 'events'

class Client
  include Logging

  def initialize(game, websocket)
    info("New connection")
    @game, @websocket = game, websocket
    @player = Player.new(game)
    @game.add_player(@player)
    @player.send_position
    @game.subscribe { |event| send_event(event) }
    websocket.onmessage { |msg| process_message(msg) }
  end

  def process_message(msg)
    debug("Recieved message: #{msg}")
    event = Events::Base.parse(msg)
    case event
    when Events::Move
      @player.move(event.direction)
    when Events::Delete
      # TODO
    end
  end

  def send_event(event)
    @websocket.send(event.to_json)
  end
end
