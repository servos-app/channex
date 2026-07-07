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

      # List webhooks with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      # Create a new webhook
      #
      # @param attributes [Hash] Webhook attributes
      #   - property_id [String] Property UUID (required)
      #   - callback_url [String] URL to receive webhook POST requests (required)
      #   - event_mask [String] Event type or "*" for all (required)
      #   - is_active [Boolean] Whether webhook is active (default: false)
      #   - send_data [Boolean] Include payload data in callback (default: false)
      #   - headers [Hash] Custom headers for authentication (optional)
      #   - request_params [Hash] GET arguments for the callback URL (optional)
      # @return [Response]
      def create(attributes)
        client.post(resource_path, body: {webhook: attributes})
      end

      # Update an existing webhook
      #
      # @param id [String] Webhook UUID
      # @param attributes [Hash] Webhook attributes to update
      # @return [Response]
      def update(id, attributes)
        client.put("#{resource_path}/#{id}", body: {webhook: attributes})
      end

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
    end
  end
end
