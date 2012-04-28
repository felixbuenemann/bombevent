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
    explosion = Explosion.new(game, coordinates)
    explosion.add_to_game
    explosion.send_position
  end
end
