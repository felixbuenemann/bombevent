require 'json'

module Events
  class Base
    def as_json(*)
      {
        type: json_type
      }
    end

    def json_type
      self.class.name.downcase.gsub('events::', '')
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
