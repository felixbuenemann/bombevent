require 'game_object'

class Block
  include GameObject

  def initialize(game, coordinates)
    self.game = game
    self.coordinates = coordinates
  end
end
