require 'eventmachine'
require 'game_object'
require 'events/position'

class Explosion
  include GameObject

  def initialize(game, coordinates, seconds = 1, callback = nil)
    super(game, coordinates)
    game.add_timer(seconds) { delete }
    @on_destroy_objects_callback = callback
    @subscription_name = game.subscribe { |event| destroy_objects if event.kind_of?(Events::Position) }

    destroy_objects
  end

  def delete
    game.unsubscribe(@subscription_name)
    super
  end

  def destroy_objects
    game.destroyable_objects_at(*coordinates).each do |object|
      @on_destroy_objects_callback.call(object) if @on_destroy_objects_callback
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
