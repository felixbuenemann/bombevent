require 'game_object'

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
    true # FIXME
  end
end

