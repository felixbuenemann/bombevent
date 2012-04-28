require 'em/channel'

class Game
  attr_reader :players

  def initialize(map_size = [15,11])
    @channel  = EventMachine::Channel.new
    @players  = Array.new
    @map_size = size
  end

  def subscribe(&block)
    @channel.subscribe(&block)
  end

  def add_player(player)
    @players << player
  end

  def send(event)
    @channel.push(event)
  end
end
