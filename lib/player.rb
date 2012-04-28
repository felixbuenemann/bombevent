require 'game_object'
require 'bomb'

class Player
  include GameObject

  def initialize(game)
    self.game = game
    self.coordinates = [0.0, 0.0]
  end

  def move(direction)
    new_coordinates = coordinates.dup
    case direction.to_sym
    when :up
      new_coordinates[1] -= 0.2
    when :down
      new_coordinates[1] += 0.2
    when :left
      new_coordinates[0] -= 0.2
    when :right
      new_coordinates[0] += 0.2
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
    bomb = Bomb.new(game, round_coordinates)
    bomb.add_to_game
    bomb.send_position
  end

  def solid?
    false
  end
end

