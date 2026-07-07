module Channex
  module Resources
    # Messages API resource
    #
    # Messages represent chat communications from booking channels.
    # Currently supports messages from Booking.com and Airbnb.
    #
    # @example List messages for a booking
    #   client.messages.list(booking_id: "booking-uuid")
    #
    # @example Send a message
    #   client.messages.create(
    #     booking_id: "booking-uuid",
    #     message: "Thank you for your reservation!"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/messages-collection
    #
    class Messages < Resource
      # List messages with optional filtering
      #
      # @param booking_id [String] Filter by booking UUID
      # @param thread_id [String] Filter by message thread UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(booking_id: nil, thread_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:booking_id] = booking_id if booking_id
        filter[:thread_id] = thread_id if thread_id
        super(filter: filter, **options)
      end

      # Send a message
      #
      # @param booking_id [String] Booking UUID
      # @param message [String] Message text
      # @param attributes [Hash] Additional message attributes
      # @return [Response]
      def send_message(booking_id:, message:, **attributes)
        create(attributes.merge(booking_id: booking_id, message: message))
      end

      protected

      def resource_path
        "/messages"
      end
    end
  end
end
