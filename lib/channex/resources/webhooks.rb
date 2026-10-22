module Channex
  module Resources
    # Webhooks API resource
    #
    # Webhooks allow you to receive push notifications about changes
    # in your property's data, including ARI changes and booking events.
    #
    # Available webhook events:
    # - *: All events
    # - ari: ARI changes (availability, rates, restrictions)
    # - booking: All booking changes (new, modified, cancelled)
    # - booking_new: Only new bookings
    # - booking_modification: Only modified bookings
    # - booking_cancellation: Only cancelled bookings
    # - reservation_request: Airbnb reservation requests
    # - new_channel: Channel connected
    # - updated_channel: Channel updated
    # - disconnected_channel: Channel disconnected
    # - message: New message received
    #
    # ARI events support filtering by restriction type, room type, and rate plan:
    #   Format: "ari:restrictions:room_type_ids:rate_plan_ids"
    #   Example: "ari:rate:*:96a44e07-2158-43e4-8baa-8f6f56922ba8"
    #
    # @example Create a webhook for all events
    #   client.webhooks.create(
    #     property_id: "property-uuid",
    #     callback_url: "https://your-domain.com/webhooks/channex",
    #     event_mask: "*",
    #     is_active: true,
    #     send_data: true
    #   )
    #
    # @example Create a webhook for specific rate plan changes
    #   client.webhooks.create(
    #     property_id: "property-uuid",
    #     callback_url: "https://your-domain.com/webhooks/ari",
    #     event_mask: "ari:rate:*:96a44e07-2158-43e4-8baa-8f6f56922ba8",
    #     is_active: true,
    #     send_data: true
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/webhook-collection
    #
    class Webhooks < Resource
      # Standard event types
      EVENTS = %w[
        ari
        booking
        booking_new
        booking_modification
        booking_cancellation
        reservation_request
        new_channel
        updated_channel
        disconnected_channel
        message
      ].freeze

      # Test a webhook endpoint without saving
      #
      # @param attributes [Hash] Webhook attributes to test
      # @return [Response]
      def test_new(attributes)
        client.post("#{resource_path}/test", body: {webhook: attributes})
      end

      # Test an existing webhook endpoint
      #
      # @param id [String] Webhook UUID
      # @return [Response]
      def test(id)
        client.post("#{resource_path}/#{id}/test", body: {})
      end

      protected

      def resource_path
        "/webhooks"
      end

      def filter_keys
        %i[property_id]
      end
    end
  end
end
