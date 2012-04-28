require 'json'

module Events
  class Base
    attr_accessor :game_object

    def as_json(*)
      {
        type:   self.class.name.downcase.gsub('events::',''),
        game_object: game_object,
      }
    end

    def to_json(*)
      JSON(as_json)
    end

    def initialize(opts = {})
      opts.each do |key, value|
        public_send "#{key}=", value
      end
    end

    def self.parse(json)
      case json
      when String
        parse(JSON(json))
      when Hash
        type = json.delete('type').capitalize
        klass = Events.const_get(type)
        klass.new json
      else
        raise "needs JSON String or Hash"
      end
    end
  end
end
