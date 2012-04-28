require 'em/channel'
require 'block'

class Game
  attr_reader :map_size

  def initialize(map_size = [15,11])
    @channel  = EventMachine::Channel.new
    @players  = Array.new
    @bombs = Array.new
    @blocks = Array.new
    @map_size = map_size
    init_map
  end

  def init_map
    [[2, 2], [2, 3], [2, 4], [3, 5]].each do |coordinate|
      @blocks << Block.new(self, coordinate)
    end
  end

  def subscribe(&block)
    @channel.subscribe(&block)
  end

  def add_player(player)
    @players << player
  end

  def add_bomb(bomb)
    @bombs << bomb
  end

  def send(event)
    @channel.push(event)
  end

  def game_objects
    @players + @bombs + @blocks
  end
end
