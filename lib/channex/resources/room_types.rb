module Channex
  module Resources
    # Room Types API resource
    #
    # Room Types represent the different types of rooms available at a property.
    #
    # @example List room types for a property
    #   client.room_types.list(property_id: "property-uuid")
    #
    # @example Create a room type
    #   client.room_types.create(
    #     property_id: "property-uuid",
    #     title: "Deluxe King Room",
    #     count_of_rooms: 10,
    #     occ_adults: 2,
    #     occ_children: 1,
    #     occ_infants: 1
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/room-types-collection
    #
    class RoomTypes < Resource
      # List room types with optional filtering
      #
      # @param property_id [String] Filter by property UUID (required for most operations)
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      protected

      def resource_path
        "/room_types"
      end

      def resource_name
        "room_type"
      end
    end
  end
end
