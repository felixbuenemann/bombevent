require 'events/base'

module Events
  class Position < Base
    def initialize(object)
      @object = object
    end

    def as_json(*)
      super.merge(
        id:          @object.id,
        coordinates: @object.coordinates,
        object_type: @object.object_type,
        direction:   @object.direction,
        player_number: @object.player_number
      )
    end
  end
end
