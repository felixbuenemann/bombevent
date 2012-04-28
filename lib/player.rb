require 'game_object'

class Player
  include GameObject

  def initialize(game)
    @game = game
  end

  def move(direction)
    case direction
    when :up
      coordinates[1] -= 1
    when :down
      coordinates[1] += 1
    when :left
      coordinates[0] += 1
    when :right
      coordinates[0] -= 1
    end

    @game.send(Events::Move.new())
  end
end

