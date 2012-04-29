module Events
  class Score < Base
    attr_accessor :nickname, :player_id, :score
  end

  def as_json(*)
    super.merge(
      nickname:  nickname,
      player_id: player_id,
      score:     score,
    )
  end
end
