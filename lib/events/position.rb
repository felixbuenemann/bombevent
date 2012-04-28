require 'events/base'

module Events
  class Position < Base
    def initialize(object, coordinates)
      @object, @coordinates = object, coordinates
    end

    def as_json(*)
      super.merge(id: @object.id, coordinates: @coordinates)
    end
  end
end
