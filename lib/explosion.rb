require 'eventmachine'
require 'game_object'

class Explosion
  include GameObject

  def initialize(game, coordinates, seconds = 1)
    self.game = game
    self.coordinates = coordinates
    game.destroyable_objects_at(*coordinates).each do |object|
      object.delete
    end
    EventMachine::add_timer(seconds) { delete }
  end

  def destroyable?
    false
  end
end

