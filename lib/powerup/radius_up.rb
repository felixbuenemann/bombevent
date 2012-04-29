require 'powerup'

class RadiusUp < Powerup
  def pickup(player)
    player.explosion_size += 1
  end
end
