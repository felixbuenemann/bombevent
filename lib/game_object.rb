module GameObject
  attr_accessor :coordinates, :game, :direction, :player_number

  def initialize(game, coordinates)
    @game, @coordinates = game, coordinates
    @delete_callbacks = Array.new
  end

  def on_delete(&block)
    @delete_callbacks << block
  end

  def id
    self.object_id
  end

  def object_type
    self.class.name.downcase
  end

  def send_position
    game.send(Events::Position.new(self))
    self
  end

  def send_delete
    game.send(Events::Delete.new(self))
    self
  end

  def round_coordinates
    coordinates.map(&:round)
  end

  def add_to_game
    game.add_object(self)
    self
  end

  def delete_from_game
    game.delete_object(self)
    self
  end

  def delete
    delete_from_game
    send_delete
    @delete_callbacks.each { |cb| cb.call(self) } if @delete_callbacks
    self
  end

  def solid?
    true
  end

  def destroyable?
    true
  end
end
