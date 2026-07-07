module Channex
  module Objects
    # Guest occupancy information
    #
    # @example
    #   occupancy.adults       # => 2
    #   occupancy.children     # => 1
    #   occupancy.infants      # => 0
    #   occupancy.total_guests # => 3
    #
    class Occupancy < Channex::Object
      attribute :adults
      attribute :children
      attribute :infants

      # Child ages array (when provided)
      # @return [Array<Integer>]
      def ages
        @data["ages"] || []
      end

      # Total number of guests
      # @return [Integer]
      def total_guests
        (adults || 0) + (children || 0) + (infants || 0)
      end
    end
  end
end
