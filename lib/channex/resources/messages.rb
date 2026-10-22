module Channex
  module Resources
    # Booking Messages API resource
    #
    # The booking-scoped view of the same conversations {MessageThreads}
    # exposes: reach a guest by the booking you already hold, without first
    # resolving which thread it belongs to. Channex answers 422 `not_supported`
    # for bookings from an OTA that has no messaging API.
    #
    # Requires the Messages application to be installed on the property.
    #
    # @example Read the conversation on a booking
    #   client.messages.list(booking_id: "booking-uuid")
    #
    # @example Answer the guest
    #   client.messages.send_message(
    #     booking_id: "booking-uuid",
    #     message: "Thank you for your reservation!"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/messages-collection
    #
    class Messages < Resource
      # List the messages on a booking, newest first by default
      #
      # @param booking_id [String] Booking UUID
      # @param options [Hash] Additional options (page, limit, filter, order)
      # @return [Response]
      def list(booking_id:, **options)
        client.get(booking_path(booking_id), params: query_params(**options))
      end

      # Send a message to the guest on a booking
      #
      # Pass `attachment_id` to send a file previously uploaded through
      # {Attachments#create}; `message` and `attachment_id` can be combined to
      # send a file with a caption.
      #
      # @param booking_id [String] Booking UUID
      # @param message [String] Message text
      # @param attachment_id [String] Attachment UUID from {Attachments#create}
      # @param attributes [Hash] Additional message attributes
      # @return [Response]
      def send_message(booking_id:, message: nil, attachment_id: nil, **attributes)
        attributes[:message] = message if message
        attributes[:attachment_id] = attachment_id if attachment_id

        client.post(booking_path(booking_id), body: {message: attributes})
      end

      protected

      # Messages only exist under a booking, so there is no collection of their
      # own to retrieve, update or delete.
      def resource_path
        raise NotImplementedError, "Messages are scoped to a booking — use #list or #send_message"
      end

      def booking_path(booking_id)
        "/bookings/#{booking_id}/messages"
      end
    end
  end
end
