module Events
  class MyPlayerId < Base
    def initialize(player)
      @player = player
    end

    def as_json(*)
      super.merge(
        my_player_id: player.id,
      )
    end
  end
end
