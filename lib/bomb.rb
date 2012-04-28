require 'game_object'

class Bomb
  include GameObject

  def initialize(game, coordinates)
    self.game = game
    self.coordinates = coordinates
  end
end
