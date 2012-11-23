module Presence
  # Raised when the presence command is executed in an unsupported environment.
  class InvalidEnvironment < StandardError; end

  # Raised when an invalid listener is registered with the Presence::Scanner.
  class InvalidListener < StandardError; end
end
