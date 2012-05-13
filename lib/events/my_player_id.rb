module Events
  class MyPlayerId < Base
    def initialize(player)
      @player = player
    end

    def as_json(*)
      super.merge(
        player_id: @player.id,
      )
    end
  end
end
