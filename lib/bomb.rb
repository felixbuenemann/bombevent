require 'eventmachine'
require 'game_object'
require 'explosion'
require 'logging'

class Bomb
  include GameObject
  include Logging

  def initialize(game, coordinates)
    self.game = game
    self.coordinates = coordinates
    EventMachine::add_timer(3) { explode }
  end

  def explode
    info("Booooooooooooooooom")
    delete
    x, y = coordinates
    add_explosion_at(x, y)
    [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]].each do |xn, yn|
      add_explosion_at(xn, yn) unless game.non_destroyable_object_at?(xn, yn)
    end
  end

  def add_explosion_at(x, y)
    explosion = Explosion.new(game, [x, y])
    explosion.add_to_game
    explosion.send_position
  end

  def solid?
    false
  end
end
