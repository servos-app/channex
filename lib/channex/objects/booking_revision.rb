module Channex
  module Objects
    # Booking revision from Channex API
    #
    # Booking revisions are snapshots of bookings at a given time.
    # Each time an OTA provides an update, a new revision is created.
    #
    # @example Basic usage
    #   revision.id                      # => "uuid"
    #   revision.status                  # => "new"
    #   revision.new?                    # => true
    #   revision.customer.full_name      # => "John Doe"
    #   revision.rooms.first.nights      # => 3
    #
    # @example Hash access still works
    #   revision["booking_id"]           # => "uuid"
    #   revision.dig("customer", "mail") # => "john@example.com"
    #
    class BookingRevision < Channex::Object
      # Core identifiers
      attribute :id
      attribute :booking_id
      attribute :property_id
      attribute :unique_id
      attribute :system_id

      # OTA information
      attribute :ota_name
      attribute :ota_reservation_code

      # Status and timing
      attribute :status
      attribute :inserted_at

      # Booking dates
      attribute :arrival_date
      attribute :departure_date
      attribute :arrival_hour

      # Financial
      attribute :amount
      attribute :currency
      attribute :ota_commission
      attribute :payment_collect
      attribute :payment_type

      # Other
      attribute :notes

      # Nested objects
      attribute :customer, type: Customer
      attribute :occupancy, type: Occupancy
      attribute :guarantee, type: Guarantee

      # Arrays
      array_attribute :rooms, type: BookingRoom
      array_attribute :services, type: Service

      # Status check helpers
      # @return [Boolean]
      def new?
        status == "new"
      end

      # @return [Boolean]
      def modified?
        status == "modified"
      end

      # @return [Boolean]
      def cancelled?
        status == "cancelled"
      end

      # Arrival date as Date object
      # @return [Date, nil]
      def check_in_date
        Date.parse(arrival_date) if arrival_date
      end

      # Departure date as Date object
      # @return [Date, nil]
      def check_out_date
        Date.parse(departure_date) if departure_date
      end

      # Timestamp when revision was received
      # @return [Time, nil]
      def received_at
        Time.parse(inserted_at) if inserted_at
      end

      # Total booking amount as Money object (if money gem is available)
      # @return [Money, nil]
      def total_amount
        return nil unless amount && currency
        return nil unless defined?(Money)

        Money.from_amount(BigDecimal(amount.to_s), currency)
      end

      # OTA commission as Money object (if money gem is available)
      # @return [Money, nil]
      def commission_amount
        return nil unless ota_commission && currency
        return nil unless defined?(Money)

        Money.from_amount(BigDecimal(ota_commission.to_s), currency)
      end

      # Whether payment should be collected by the property
      # @return [Boolean]
      def collect_payment?
        payment_collect == "property" || payment_collect.nil?
      end

      # Whether payment was already collected by the OTA
      # @return [Boolean]
      def prepaid?
        payment_collect == "ota"
      end
    end
  end
end
