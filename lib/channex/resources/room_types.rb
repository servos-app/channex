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
      protected

      def resource_path
        "/room_types"
      end

      def filter_keys
        %i[property_id]
      end
    end
  end
end
