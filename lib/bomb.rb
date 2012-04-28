require 'eventmachine'
require 'game_object'

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
  end
end
