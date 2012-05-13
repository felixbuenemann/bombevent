require 'json'

module Events
  class Base
    def as_json(*)
      {
        type: json_type
      }
    end

    def json_type
      self.class.name.gsub('Events::', '').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
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
        type = json.delete('type').split(/_/).map(&:capitalize).join
        klass = Events.const_get(type)
        klass.new json
      when Array
        json.map { |v| parse(v) }
      else
        raise "needs JSON String or Hash"
      end
    end
  end
end
