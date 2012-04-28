require 'game_object'

class Wall
  include GameObject

  def initialize(game, coordinates)
    self.game = game
    self.coordinates = coordinates
  end

  def destroyable?
    false
  end
end
