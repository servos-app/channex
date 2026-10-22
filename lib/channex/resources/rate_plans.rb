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
      protected

      def resource_path
        "/rate_plans"
      end

      def filter_keys
        %i[property_id room_type_id]
      end
    end
  end
end
