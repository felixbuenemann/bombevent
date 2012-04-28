require 'logger'

module Logging
  @@logger = Logger.new(STDOUT)

  def log(serverity, msg)
    @@logger.log(serverity, msg)
  end

  %w(debug info warn error).each do |severity|
    define_method(severity.to_sym) do |msg|
      @@logger.send(severity.to_sym, msg)
    end
  end
end
