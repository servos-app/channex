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

      protected

      def resource_path
        "/availability_rules"
      end

      def filter_keys
        %i[property_id]
      end
    end
  end
end
