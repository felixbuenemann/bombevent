require 'powerup'

class BombUp < Powerup
  def pickup(player)
    player.max_bombs += 1
  end
end
