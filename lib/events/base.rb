require 'json'

module Events
  class Base
    attr_accessor :game_object

    def as_json(*)
      {
        type:   self.class.name.downcase.gsub('events::',''),
        object: game_object,
      }
    end

    def to_json(*)
      JSON(as_json)
    end
  end
end
