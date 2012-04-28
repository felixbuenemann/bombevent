require 'game_object'
require 'bomb'

class Player
  include GameObject

  SPEED = 0.2
  INITIAL_MAX_BOMBS = 3

  attr_accessor :max_bombs

  def initialize(game)
    self.game = game
    self.coordinates = game.next_spawn_position
    @bombs = Array.new
    @max_bombs = INITIAL_MAX_BOMBS
    @dead = false
    @explosion_size = 3
  end

  def delete
    @dead = true
    super
  end

  def move(direction)
    return if @dead
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
    self.coordinates = new_coordinates if valid_coordinates?(*new_coordinates)
    send_position
  end

  def valid_coordinates?(x, y)
    (0..game.map_size[0]).include?(x) &&
      (0..game.map_size[1]).include?(y) &&
      !game.solid_object_at?(x,y)
  end

  def place_bomb
<<<<<<< HEAD
    return if @dead || @bombs.count >= @max_bombs
    bomb = Bomb.new(game, round_coordinates)
=======
    return if @bombs.count >= @max_bombs
    bomb = Bomb.new(game, round_coordinates, @explosion_size)
>>>>>>> adds bomb radius
    @bombs << bomb
    bomb.add_to_game
    bomb.send_position
    bomb.on_explode { |bomb| @bombs.delete(bomb) }
  end

  def solid?
    false
  end
end

