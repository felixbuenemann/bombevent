module Events
  class Join < Base
    attr_accessor :nickname

    def as_json(*)
      super.merge(nickname: nickname)
    end
  end
end
