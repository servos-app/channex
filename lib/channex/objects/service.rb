module Channex
  module Objects
    # Additional service, fee, or extra sold alongside a booking.
    #
    # Channex represents meals, fees, and extras uniformly in a booking's
    # `services` array (present at both booking and room level), distinguished
    # by `type`. A fee charged on a cancelled booking also arrives here — note
    # that real OTA payloads use a specific `type` (e.g. Booking.com sends
    # "Cancellation Fee"), not the generic "Fee" the API docs imply.
    #
    # `is_inclusive` indicates whether tax is already baked into the amount.
    #
    # @see https://docs.channex.io/api-v.1-documentation/bookings-collection
    #
    # @example
    #   service.type           # => "Cancellation Fee"
    #   service.name           # => "Cancellation Fee"
    #   service.total_price    # => "12240.00" (total amount for the service)
    #   service.price_per_unit # => "12240.00"
    #   service.price_mode     # => "Per stay"
    #   service.nights         # => 0
    #   service.persons        # => 0
    #   service.inclusive?     # => true
    #   service.room_index     # => 0 (room the service is associated with, if any)
    #
    class Service < Channex::Object
      attribute :type
      attribute :name
      attribute :total_price
      attribute :price_per_unit
      attribute :price_mode
      attribute :persons
      attribute :nights
      attribute :room_index
      attribute :inclusive, key: "is_inclusive"

      # Whether tax is already included in the amount
      # @return [Boolean]
      def inclusive?
        inclusive == true
      end
    end
  end
end
