require 'em/channel'
require 'block'

class Game
  attr_reader :map_size
  attr_reader :game_objects

  def initialize(map_size = [15,11])
    @channel  = EventMachine::Channel.new
    @game_objects  = Array.new
    @map_size = map_size
    init_map
  end

  def init_map
    [[2, 2], [2, 3], [2, 4], [3, 5]].each do |coordinate|
      @game_objects << Block.new(self, coordinate)
    end
  end

  def subscribe(&block)
    @channel.subscribe(&block)
  end

  def unsubscribe(name)
    @channel.unsubscribe(name)
  end

  def add_object(object)
    @game_objects << object
  end

  def delete_object(object)
    @game_objects.delete(object)
  end

  def send(event)
    @channel.push(event)
  end

  def objects_at(x, y)
    game_objects.select do |game_object|
      x > (game_object.coordinates[0] - 1) &&
        x < (game_object.coordinates[0] + 1) &&
        y > (game_object.coordinates[1] - 1) &&
        y < (game_object.coordinates[1] + 1)
    end
  end

  def solid_object_at?(x, y)
    objects_at(x, y).any?(&:solid?)
  end

  def destroyable_objects_at(x, y)
    objects_at(x, y).select(&:destroyable?)
  end
end
