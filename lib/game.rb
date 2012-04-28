require 'em/channel'

class Game
  def initialize
    @channel = EventMachine::Channel.new
    @players = Array.new
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
