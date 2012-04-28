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

  # if object at 3,3 I can't got to 2,3 but not 2.1,3
  def object_at?(x, y)
    game.game_objects.any? do |game_object|
      x > (game_object.coordinates[0] - 1) &&
        x < (game_object.coordinates[0] + 1) &&
        y > (game_object.coordinates[1] - 1) &&
        y < (game_object.coordinates[1] + 1)
    end
  end
end
