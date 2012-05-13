require 'game_object'
require 'bomb'

class Player
  include GameObject

  SPEED = 0.125
  PRECISION = 3
  CORNER_FUZZ_FACTOR = 4
  INITIAL_MAX_BOMBS = 1

  attr_accessor :max_bombs, :explosion_size, :points
  attr_reader :nickname

  @@player_counter = 0

  def initialize(game, nickname)
    super(game, game.next_spawn_position)
    @bombs = Array.new
    @max_bombs = INITIAL_MAX_BOMBS
    @dead = false
    @explosion_size = 1
    @nickname = nickname
    @points = 0
    @@player_counter += 1
    self.player_number = @@player_counter
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
      new_coordinates[1] = (new_coordinates[1] - SPEED).round(PRECISION)
    when :down
      new_coordinates[1] = (new_coordinates[1] + SPEED).round(PRECISION)
    when :left
      new_coordinates[0] = (new_coordinates[0] - SPEED).round(PRECISION)
    when :right
      new_coordinates[0] = (new_coordinates[0] + SPEED).round(PRECISION)
    end
    if valid_coordinates?(*new_coordinates)
      self.coordinates = new_coordinates
    else
      self.coordinates = calculate_alternative_coordinates(
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

  def calculate_alternative_coordinates(old_coords, new_coords, direction)
    horizontal = [ :left, :right ]
    vertical   = [ :up,   :down  ]
    range = -(SPEED*CORNER_FUZZ_FACTOR)..(SPEED*CORNER_FUZZ_FACTOR)
    if horizontal.include? direction
      y = new_coords[1]
      range.step(SPEED) do |step|
        new_coords[1] = (y + step).round(PRECISION)
        return new_coords if valid_coordinates? *new_coords
      end
    elsif vertical.include? direction
      x = new_coords[0]
      range.step(SPEED) do |step|
        new_coords[0] = (x + step).round(PRECISION)
        return new_coords if valid_coordinates? *new_coords
      end
    end
    old_coords
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

  def points=(points)
    @points = points
    game.send(Events::Score.new(nickname: nickname, player_id: id, score: @points))
  end

  def solid?
    false
  end
end

