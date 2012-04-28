require 'events/base'

module Events
  class Delete < Base
    def initialize(object)
      @object = object
    end

    def as_json(*)
      super.merge(id: @object.id, object_type: @object.object_type)
    end
  end
end
