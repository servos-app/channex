module Channex
  module Resources
    # Message Threads API resource
    #
    # A message thread is one guest conversation, normalised by Channex across
    # Booking.com, Airbnb and Expedia. Threads are the channel-agnostic entry
    # point: they exist even when there is no booking to hang them off (an
    # Airbnb inquiry), which booking-scoped messages cannot represent.
    #
    # Requires the Messages application to be installed on the property —
    # without it every call in here answers 403 Forbidden.
    #
    # @example List the open threads for a property
    #   client.message_threads.list(property_id: "property-uuid")
    #
    # @example Read a conversation
    #   client.message_threads.messages("thread-uuid", order: {inserted_at: :asc})
    #
    # @example Reply to the guest
    #   client.message_threads.send_message("thread-uuid", message: "Check-in is from 15:00.")
    #
    # @see https://docs.channex.io/api-v.1-documentation/messages-collection
    #
    class MessageThreads < Resource
      # List message threads with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param booking_id [String] Filter by booking UUID
      # @param options [Hash] Additional options (page, limit, filter, order)
      # @return [Response]
      def list(property_id: nil, booking_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        filter[:booking_id] = booking_id if booking_id
        super(filter: filter, **options)
      end

      # List the messages on a thread, newest first by default
      #
      # @param id [String] Thread UUID
      # @param options [Hash] Additional options (page, limit, filter, order)
      # @return [Response]
      def messages(id, **options)
        client.get("#{resource_path}/#{id}/messages", params: query_params(**options))
      end

      # Send a message to the guest on a thread
      #
      # Pass `attachment_id` to send a file previously uploaded through
      # {Attachments#create}; `message` and `attachment_id` can be combined to
      # send a file with a caption.
      #
      # @param id [String] Thread UUID
      # @param message [String] Message text
      # @param attachment_id [String] Attachment UUID from {Attachments#create}
      # @param attributes [Hash] Additional message attributes
      # @return [Response]
      def send_message(id, message: nil, attachment_id: nil, **attributes)
        client.post(
          "#{resource_path}/#{id}/messages",
          body: {message: message_attributes(message:, attachment_id:, **attributes)}
        )
      end

      # Close a thread
      #
      # @param id [String] Thread UUID
      # @return [Response]
      def close(id)
        client.post("#{resource_path}/#{id}/close", body: {})
      end

      # Mark a thread as needing no reply (Booking.com only)
      #
      # Booking.com scores properties on how fast they answer, but some guest
      # messages do not call for an answer at all. Marking the thread keeps the
      # response-time score honest instead of leaving the clock running.
      #
      # @param id [String] Thread UUID
      # @return [Response]
      def no_reply_needed(id)
        client.post("#{resource_path}/#{id}/no_reply_needed", body: {})
      end

      protected

      def resource_path
        "/message_threads"
      end

      def resource_name
        "message_thread"
      end

      def message_attributes(message: nil, attachment_id: nil, **attributes)
        attributes[:message] = message if message
        attributes[:attachment_id] = attachment_id if attachment_id
        attributes
      end
    end
  end
end
