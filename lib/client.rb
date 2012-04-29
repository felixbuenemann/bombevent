require 'logging'
require 'player'
require 'game'
require 'events'

class Client
  include Logging

  def initialize(game, websocket)
    info("New connection")
    @game, @websocket = game, websocket
    @subscription_name = @game.subscribe { |event| send_event(event) }
    websocket.onmessage { |msg| process_message(msg) }
    websocket.onclose { close }
  end

  def join
    @player = Player.new(@game)
    @player.add_to_game
    send_event Events::MyPlayerId.new(@player)
    @player.send_position
  end

  def process_message(msg)
    debug("Recieved message: #{msg}")
    events = Events::Base.parse(msg)
    events.each { |event| process_event(event) }
  end

  def process_event(event)
    case event
    when Events::Join
      join
    when Events::Move
      @player.move(event.direction)
    when Events::PlaceBomb
      @player.place_bomb
    when Events::LoadMap
      events = @game.game_objects.map do |object|
        Events::Position.new object
      end
      send_event(events)
    end
  end

  def send_event(event)
    debug("Send event: #{Array(event).to_json}")
    @websocket.send(Array(event).to_json)
  end

  def close
    info("Player left")
    @game.unsubscribe(@subscription_name)
    @player.delete if @player
  end
end
