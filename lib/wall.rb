require 'game_object'

class Wall
  include GameObject

  def destroyable?
    false
  end
end
