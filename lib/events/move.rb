module Events
  class Move < Base
    attr_accessor :direction

    def as_json(*)
      super.merge(
        direction: direction
      )
    end
  end
end
