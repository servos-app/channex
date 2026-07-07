module Channex
  module Resources
    # Availability API resource
    #
    # Availability represents how many rooms your property has to sell.
    # This is the core data for inventory management in Channex.
    #
    # @example Get availability for a property
    #   client.availability.list(
    #     property_id: "property-uuid",
    #     date_from: "2024-01-01",
    #     date_to: "2024-01-31"
    #   )
    #
    # @example Update availability for specific dates
    #   client.availability.update([
    #     {
    #       property_id: "property-uuid",
    #       room_type_id: "room-uuid",
    #       date_from: "2024-01-15",
    #       date_to: "2024-01-20",
    #       availability: 5
    #     }
    #   ])
    #
    # @see https://docs.channex.io/api-v.1-documentation/ari
    #
    class Availability < Resource
      # Get availability for a property within a date range
      #
      # @param property_id [String] Property UUID (required)
      # @param date [String] Specific date (YYYY-MM-DD)
      # @param date_from [String] Start date (YYYY-MM-DD), uses filter[date][gte]
      # @param date_to [String] End date (YYYY-MM-DD), uses filter[date][lte]
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id:, date: nil, date_from: nil, date_to: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id

        if date
          filter[:date] = date
        else
          filter[:date] = {}
          filter[:date][:gte] = date_from if date_from
          filter[:date][:lte] = date_to if date_to
        end

        client.get(resource_path, params: {filter: filter, **options})
      end

      # Update availability for properties
      #
      # Each value in the array should contain all required fields including property_id.
      # You can update multiple properties and room types in a single request.
      #
      # @param values [Array<Hash>] Array of availability updates
      #   Each hash should contain:
      #   - property_id [String] Property UUID (required)
      #   - room_type_id [String] Room Type UUID (required)
      #   - date_from [String] Start date YYYY-MM-DD (required)
      #   - date_to [String] End date YYYY-MM-DD (required)
      #   - availability [Integer] Number of available rooms (required)
      # @return [Response]
      #
      # @example Update availability for a date range
      #   client.availability.update([
      #     {
      #       property_id: "716305c4-561a-4561-a187-7f5b8aeb5920",
      #       room_type_id: "994d1375-dbbd-4072-8724-b2ab32ce781b",
      #       date_from: "2024-01-15",
      #       date_to: "2024-01-20",
      #       availability: 5
      #     }
      #   ])
      def update(values)
        client.post(resource_path, body: {values: values})
      end

      protected

      def resource_path
        "/availability"
      end
    end
  end
end
