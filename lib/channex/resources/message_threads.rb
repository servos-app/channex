module Channex
  module Resources
    # Message Threads API resource
    #
    # Message Threads represent conversation threads associated with bookings.
    # Each booking may have multiple message threads.
    #
    # @example List message threads for a booking
    #   client.message_threads.list(booking_id: "booking-uuid")
    #
    # @example Retrieve a thread with messages
    #   client.message_threads.retrieve("thread-uuid")
    #
    # @see https://docs.channex.io/api-v.1-documentation/messages-collection
    #
    class MessageThreads < Resource
      # List message threads with optional filtering
      #
      # @param booking_id [String] Filter by booking UUID
      # @param property_id [String] Filter by property UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(booking_id: nil, property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:booking_id] = booking_id if booking_id
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      # Mark a thread as read
      #
      # @param id [String] Thread UUID
      # @return [Response]
      def mark_as_read(id)
        client.post("#{resource_path}/#{id}/read", body: {})
      end

      # Mark a thread as no reply needed (Booking.com only)
      #
      # Booking.com has internal scoring based on response time. When a guest
      # provides a message that doesn't need a reply, use this to indicate
      # that so Booking.com counts the reaction time correctly.
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
    end
  end
end
