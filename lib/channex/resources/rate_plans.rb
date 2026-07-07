module Channex
  module Resources
    # Rate Plans API resource
    #
    # A Rate Plan is a pricing plan for how to sell your Room Types,
    # containing information about prices and restrictions.
    #
    # @example List rate plans for a property
    #   client.rate_plans.list(property_id: "property-uuid")
    #
    # @example Create a rate plan
    #   client.rate_plans.create(
    #     property_id: "property-uuid",
    #     room_type_id: "room-type-uuid",
    #     title: "Standard Rate",
    #     sell_mode: "per_room",
    #     rate_mode: "manual"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/rate-plans-collection
    #
    class RatePlans < Resource
      # List rate plans with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param room_type_id [String] Filter by room type UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, room_type_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        filter[:room_type_id] = room_type_id if room_type_id
        super(filter: filter, **options)
      end

      protected

      def resource_path
        "/rate_plans"
      end

      def resource_name
        "rate_plan"
      end
    end
  end
end
