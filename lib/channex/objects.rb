module Channex
  # Namespace for typed API response objects
  #
  # All objects inherit from Channex::Object and provide:
  # - Typed attribute accessors
  # - Hash compatibility via [], dig, to_h
  # - Nested object wrapping
  #
  module Objects
  end
end

# Load in dependency order (leaf nodes first)
require_relative "objects/company"
require_relative "objects/occupancy"
require_relative "objects/guest"
require_relative "objects/tax"
require_relative "objects/service"
require_relative "objects/guarantee"
require_relative "objects/customer"
require_relative "objects/booking_room"
require_relative "objects/booking_revision"
