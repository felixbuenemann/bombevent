require 'eventmachine'
require 'game_object'

class Explosion
  include GameObject

  def initialize(game, coordinates, seconds = 1)
    self.game = game
    self.coordinates = coordinates
    EventMachine::add_timer(seconds) { delete }
  end
end

