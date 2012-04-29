require 'eventmachine'
require 'game_object'

class Explosion
  include GameObject

  def initialize(game, coordinates, seconds = 1)
    super(game, coordinates)
    game.add_timer(seconds) { delete }

    @subscription_name = game.subscribe { destroy_objects }

    destroy_objects
  end

  def delete
    game.unsubscribe(@subscription_name)
    super
  end

  def destroy_objects
    game.destroyable_objects_at(*coordinates).each do |object|
      object.delete
    end
  end

  def destroyable?
    false
  end

  def solid?
    false
  end
end

