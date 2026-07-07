module Channex
  module Objects
    # Individual room within a booking revision
    #
    # @example
    #   room.room_type_id      # => "uuid"
    #   room.check_in_date     # => Date
    #   room.check_out_date    # => Date
    #   room.nights            # => 3
    #   room.occupancy.adults  # => 2
    #   room.guests.first.name # => "John"
    #
    class BookingRoom < Channex::Object
      attribute :booking_room_id
      attribute :ota_unique_id
      attribute :room_type_id
      attribute :rate_plan_id
      attribute :checkin_date
      attribute :checkout_date
      attribute :amount
      attribute :occupancy, type: Occupancy
      array_attribute :guests, type: Guest
      array_attribute :taxes, type: Tax
      array_attribute :services, type: Service

      # Check-in date as Date object
      # @return [Date, nil]
      def check_in_date
        Date.parse(checkin_date) if checkin_date
      end

      # Check-out date as Date object
      # @return [Date, nil]
      def check_out_date
        Date.parse(checkout_date) if checkout_date
      end

      # Number of nights for this room
      # @return [Integer, nil]
      def nights
        return nil unless check_in_date && check_out_date
        (check_out_date - check_in_date).to_i
      end

      def room_reservation_id
        meta["room_reservation_id"] || meta["roomreservation_id"]
      end

      # Daily price breakdown
      # @return [Hash] Date string keys mapped to price strings
      def days
        @data["days"] || {}
      end

      # Free-form metadata
      # @return [Hash]
      def meta
        @data["meta"] || {}
      end

      # Parent rate plan ID (when using derived rate plans)
      # @return [String, nil]
      def parent_rate_plan_id
        meta["parent_rate_plan_id"]
      end
    end
  end
end
