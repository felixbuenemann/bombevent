require 'game_object'
require 'events/position'

class Player
  include GameObject

  def initialize(game)
    self.game = game
    self.coordinates = [0.0, 0.0]
  end

  def move(direction)
    case direction.to_sym
    when :up
      coordinates[1] -= 0.2
    when :down
      coordinates[1] += 0.2
    when :left
      coordinates[0] -= 0.2
    when :right
      coordinates[0] += 0.2
    end
    send_position
  end
end

