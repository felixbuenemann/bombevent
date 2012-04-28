require 'em/channel'
require 'block'

class Game
  attr_reader :map_size
  attr_reader :game_objects

  def initialize(map_size = [15,11])
    @channel  = EventMachine::Channel.new
    @game_objects  = Array.new
    @map_size = map_size
    @spawn_coordinates = [
      [0,0], [0, 10], [14, 10], [14, 0]
    ]
    @spawn_index = 0
    init_map
  end

  def init_map
    15.times do |x|
      11.times do |y|
        next if [[x,y], [x+1,y], [x-1,y], [x,y+1], [x,y-1] ].any? do |coords|
          @spawn_coordinates.include? coords
        end

        @game_objects << Block.new(self, [x, y]) if rand < 0.6
      end
    end
  end

  def next_spawn_position
    @spawn_index = (@spawn_index + 1) % @spawn_coordinates.size
    @spawn_coordinates[@spawn_index]
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

  def non_destroyable_object_at?(x, y)
    objects_at(x, y).any? { |object| !object.destroyable? }
  end
end
