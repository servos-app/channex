module Channex
  module Resources
    # Facilities API resource
    #
    # Facilities represent amenities available at properties or room types.
    # This is a read-only resource providing the list of available facility IDs.
    #
    # @example List available facilities
    #   client.facilities.list
    #
    # @see https://docs.channex.io/api-v.1-documentation/facilities-collection
    #
    class Facilities < Resource
      # List available facilities
      #
      # @param options [Hash] Additional options
      # @return [Response]
      def list(**options)
        client.get(resource_path, params: options)
      end

      protected

      def resource_path
        "/facilities"
      end
    end
  end
end
