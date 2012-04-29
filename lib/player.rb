require 'game_object'
require 'bomb'

class Player
  include GameObject

  SPEED = 0.25
  INITIAL_MAX_BOMBS = 1

  attr_accessor :max_bombs, :explosion_size, :points
  attr_reader :nickname

  def initialize(game, nickname)
    super(game, game.next_spawn_position)
    @bombs = Array.new
    @max_bombs = INITIAL_MAX_BOMBS
    @dead = false
    @explosion_size = 1
    @nickname = nickname
    @points = 0
  end

  def delete
    @dead = true
    super
  end

  def move(direction)
    return if @dead
    self.direction = direction
    new_coordinates = coordinates.dup
    case direction.to_sym
    when :up
      new_coordinates[1] = (new_coordinates[1] - SPEED).round(2)
    when :down
      new_coordinates[1] = (new_coordinates[1] + SPEED).round(2)
    when :left
      new_coordinates[0] = (new_coordinates[0] - SPEED).round(2)
    when :right
      new_coordinates[0] = (new_coordinates[0] + SPEED).round(2)
    end
    if valid_coordinates?(*new_coordinates)
      self.coordinates = new_coordinates
    else
      self.coordinates = calculate_alaternative_coordinates(
        coordinates,
        new_coordinates,
        direction.to_sym)
    end
    send_position
  end

  def valid_coordinates?(x, y)
    return false unless (0..game.map_size[0] - 1).include?(x) && (0..game.map_size[1] - 1).include?(y)
    if game.solid_object_at?(x,y)
      return game.solid_objects_at(*coordinates) == game.solid_objects_at(x, y)
    end

    true
  end

  def calculate_alaternative_coordinates(old_coords, new_coords, direction)
    horizontal = [ :left, :right ]
    vertical   = [ :up,   :down  ]
    if horizontal.include? direction
      new_coords[1] = (new_coords[1] + SPEED).round(2)
      unless valid_coordinates? *new_coords
        new_coords[1] = (new_coords[1] - 2 * SPEED).round(2)
        return old_coords unless valid_coordinates? *new_coords
      end
    elsif vertical.include? direction
      new_coords[0] = (new_coords[0] + SPEED).round(2)
      unless valid_coordinates? *new_coords
        new_coords[0] = (new_coords[0] - 2 *SPEED).round(2)
        return old_coords unless valid_coordinates? *new_coords
      end
    else
      return old_coords
    end
    return new_coords
  end

  def place_bomb
    return if @dead || @bombs.count >= @max_bombs
    bomb = Bomb.new(game, round_coordinates, @explosion_size) do |object|
      if object.kind_of? Player
        object == self ? object.points -= 1 : object.points += 1
      end
    end
    @bombs << bomb
    bomb.add_to_game
    bomb.send_position
    bomb.on_explode { |bomb| @bombs.delete(bomb) }
  end

  def solid?
    false
  end
end

