module GameObject
  attr_accessor :coordinates

  def id
    self.object_id
  end

  def object_type
    self.class.name.downcase
  end
end
