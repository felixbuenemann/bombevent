module GameObject
  attr_accessor :coordinates, :game

  def id
    self.object_id
  end

  def object_type
    self.class.name.downcase
  end

  def send_position
    game.send(Events::Position.new(self))
  end

  def send_delete
    game.send(Events::Delete.new(self))
  end

  def round_coordinates
    coordinates.map(&:round)
  end

  def add_to_game
    game.add_object(self)
  end

  def delete_from_game
    game.delete_object(self)
  end

  def delete
    delete_from_game
    send_delete
  end
end
