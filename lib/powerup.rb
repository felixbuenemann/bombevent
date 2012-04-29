require 'game_object'

class Powerup
  include GameObject

  def initialize(game, coordinates)
    super
    @subscription_name = game.subscribe { try_pickup }
  end

  def delete
    game.unsubscribe(@subscription_name)
    super
  end

  def try_pickup
    players = game.players_at(*coordinates)
    if players.any?
      pickup(players.first)
      delete
    end
  end

  def pickup(player)
    puts "PICKUP #{player}"
  end

  def destroyable?
    false
  end

  def solid?
    false
  end
end
