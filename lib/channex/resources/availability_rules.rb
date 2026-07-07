module Channex
  module Resources
    # Availability Rules API resource
    #
    # Availability Rules allow you to create dynamic rules that affect
    # availability for specific channels, room types, and date ranges.
    # Rules can close out availability, set offsets, or cap maximum availability.
    #
    # @example List availability rules for a property
    #   client.availability_rules.list(property_id: "property-uuid")
    #
    # @example Create a close-out rule for specific dates
    #   client.availability_rules.create(
    #     property_id: "property-uuid",
    #     affected_channels: ["channel-uuid"],
    #     affected_room_types: ["room-type-uuid"],
    #     type: "close_out",
    #     start_date: "2024-12-24",
    #     end_date: "2024-12-26"
    #   )
    #
    # @example Create an availability offset rule
    #   client.availability_rules.create(
    #     property_id: "property-uuid",
    #     affected_channels: ["channel-uuid"],
    #     affected_room_types: ["room-type-uuid"],
    #     type: "availability_offset",
    #     value: 2,  # Reserve 2 rooms from OTA availability
    #     start_date: "2024-01-01"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/availability-rules-collection
    #
    class AvailabilityRules < Resource
      # Rule types
      TYPES = %w[close_out availability_offset max_availability].freeze

      # Days of week
      DAYS = %w[mo tu we th fr sa su].freeze

      # List availability rules with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      # Create a new availability rule
      #
      # @param attributes [Hash] Availability rule attributes
      #   - property_id [String] Property UUID (required)
      #   - affected_channels [Array<String>] Channel UUIDs to affect (required)
      #   - affected_room_types [Array<String>] Room Type UUIDs to affect (required)
      #   - type [String] Rule type (required): "close_out", "availability_offset", "max_availability"
      #   - start_date [String] Start date in YYYY-MM-DD format (required)
      #   - end_date [String] End date in YYYY-MM-DD format (optional, nil = indefinite)
      #   - value [Integer] Value for offset/max rules (required for non-close_out types)
      #   - days [Array<String>] Days to apply: "mo", "tu", "we", "th", "fr", "sa", "su" (optional)
      # @return [Response]
      #
      # @example Close out weekends for an OTA
      #   client.availability_rules.create(
      #     property_id: "property-uuid",
      #     affected_channels: ["booking-com-channel-uuid"],
      #     affected_room_types: ["deluxe-room-uuid"],
      #     type: "close_out",
      #     start_date: "2024-01-01",
      #     end_date: "2024-12-31",
      #     days: ["sa", "su"]
      #   )
      def create(attributes)
        client.post(resource_path, body: {availability_rule: attributes})
      end

      # Update an availability rule
      #
      # @param id [String] Availability Rule UUID
      # @param attributes [Hash] Availability rule attributes to update
      # @return [Response]
      def update(id, attributes)
        client.put("#{resource_path}/#{id}", body: {availability_rule: attributes})
      end

      protected

      def resource_path
        "/availability_rules"
      end

      def resource_name
        "availability_rule"
      end
    end
  end
end
