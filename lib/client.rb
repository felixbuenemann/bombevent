require 'logging'

class Client
  include Logging

  def initialize(game, websocket)
    info("New connection")
    @game, @websocket = game, websocket
  end
end
