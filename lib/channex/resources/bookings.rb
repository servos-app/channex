module Channex
  module Resources
    # Bookings API resource
    #
    # Bookings represent reservations made through channels connected to Channex.
    # For receiving new bookings, use the BookingRevisions resource with the feed endpoint.
    #
    # @example List bookings
    #   client.bookings.list(property_id: "property-uuid")
    #
    # @example Retrieve a booking
    #   client.bookings.retrieve("booking-uuid")
    #
    # @example Create a booking (requires Booking CRS App)
    #   client.bookings.create(
    #     property_id: "property-uuid",
    #     rooms: [{
    #       room_type_id: "room-type-uuid",
    #       rate_plan_id: "rate-plan-uuid",
    #       checkin_date: "2024-02-01",
    #       checkout_date: "2024-02-05",
    #       guests: [{ name: "John Doe" }]
    #     }]
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/bookings-collection
    # @see https://docs.channex.io/api-v.1-documentation/booking-crs-api
    #
    class Bookings < Resource
      # List bookings; date_from and date_to bound the arrival date
      #
      # @return [Response]
      def list(date_from: nil, date_to: nil, filter: {}, **options)
        arrival_date = {gte: date_from, lte: date_to}.compact
        filter = filter.merge(arrival_date:) if arrival_date.any?
        super(filter:, **options)
      end

      # Revise (modify) an existing booking
      #
      # @param reservation_id [String] The reservation ID (part after "-" in unique_id)
      # @param attributes [Hash] Updated booking attributes with status: "modified"
      # @return [Response]
      def revise(reservation_id, attributes)
        client.post(
          "#{resource_path}/revise",
          body: {
            booking: attributes.merge(reservation_id: reservation_id, status: "modified")
          }
        )
      end

      # Cancel a booking
      #
      # @param reservation_id [String] The reservation ID
      # @return [Response]
      def cancel(reservation_id)
        client.post(
          "#{resource_path}/revise",
          body: {
            booking: {
              reservation_id: reservation_id,
              status: "cancelled"
            }
          }
        )
      end

      protected

      def resource_path
        "/bookings"
      end

      def filter_keys
        %i[property_id channel_id status]
      end
    end
  end
end
