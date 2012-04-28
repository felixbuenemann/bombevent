module Events
  class Position < Base
    def initialize
    def as_json(*)
      super.merge()
  end
end
