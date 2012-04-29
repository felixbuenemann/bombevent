require 'em/channel'
require 'block'
require 'wall'
require 'powerup/bomb_up'
require 'powerup/radius_up'

class Game
  attr_reader :map_size
  attr_reader :game_objects

  def initialize(map_size = [15,11])
    @channel  = EventMachine::Channel.new
    @map_size = map_size
    init
  end

  def init
    @game_objects  = Array.new
    @spawn_coordinates = [
      [0,0], [0, 10], [14, 10], [14, 0]
    ]
    @spawn_index = 0
    @running = true
    @timers = Array.new
    init_map
  end

  def init_map
    15.times do |x|
      11.times do |y|
        next if [[x,y], [x+1,y], [x-1,y], [x,y+1], [x,y-1] ].any? do |coords|
          @spawn_coordinates.include? coords
        end

        case rand
        when 0...0.1
          @game_objects << Wall.new(self, [x, y])
        when 0.1...0.6
          block = Block.new(self, [x, y]).send_position.add_to_game
          block.on_delete do |block|
            case rand
            when 0...0.1
              Bomb.new(self, block.coordinates).send_position.add_to_game
            when 0.1...0.3
              BombUp.new(self, block.coordinates).send_position.add_to_game
            when 0.3...0.5
              RadiusUp.new(self, block.coordinates).send_position.add_to_game
            end
          end
        end
      end
    end
  end

  def add_timer(seconds, &block)
    @timers << EventMachine::Timer.new(seconds, &block)
  end

  def reset
    send(Events::GameEnd.new) if @running
    @timers.each { |timer| timer.cancel }
    @running = false
    EventMachine::add_timer(5) do
      send(Events::Reset.new)
      init
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

    #reset if object.kind_of?(Player) && all_players.count <= 1
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

  def all_players
    @game_objects.select { |o| o.kind_of?(Player) }
  end

  def players_at(x, y)
    objects_at(x, y).select { |o| o.kind_of?(Player) }
  end

  def solid_object_at?(x, y)
    objects_at(x, y).any?(&:solid?)
  end

  def solid_objects_at(x, y)
    objects_at(x, y).select(&:solid?)
  end

  def destroyable_objects_at(x, y)
    objects_at(x, y).select(&:destroyable?)
  end

  def destroyable_objects_at?(x, y)
    destroyable_objects_at(x, y).size > 0
  end

  def non_destroyable_object_at?(x, y)
    objects_at(x, y).any? { |object| !object.destroyable? }
  end

  def running?
    @running
  end
end
