module Channex
  module Resources
    # Properties API resource
    #
    # A Property represents a physical premises - hotels, motels, lodges,
    # cabins, chalets, luxury apartments, etc.
    #
    # @example List all properties
    #   client.properties.list
    #
    # @example Create a property
    #   client.properties.create(
    #     title: "My Hotel",
    #     currency: "USD",
    #     timezone: "America/New_York",
    #     property_type: "hotel",
    #     settings: { allow_availability_autoupdate: true }
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/hotels-collection
    #
    class Properties < Resource
      # Retrieve property health status
      #
      # @param id [String] Property UUID
      # @return [Response]
      def health(id)
        client.get("#{resource_path}/#{id}/health")
      end

      protected

      def resource_path
        "/properties"
      end

      def filter_keys
        %i[group_id]
      end
    end
  end
end
