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
      # List bookings with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param channel_id [String] Filter by channel UUID
      # @param status [String] Filter by status (new, modified, cancelled)
      # @param date_from [String] Filter by arrival date from
      # @param date_to [String] Filter by arrival date to
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, channel_id: nil, status: nil, date_from: nil, date_to: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        filter[:channel_id] = channel_id if channel_id
        filter[:status] = status if status

        if date_from || date_to
          filter[:arrival_date] = {}
          filter[:arrival_date][:gte] = date_from if date_from
          filter[:arrival_date][:lte] = date_to if date_to
        end

        super(filter: filter, **options)
      end

      # Create a new booking (requires Booking CRS App installed on property)
      #
      # @param attributes [Hash] Booking attributes
      # @return [Response]
      def create(attributes)
        client.post(resource_path, body: {booking: attributes})
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
    end
  end
end
