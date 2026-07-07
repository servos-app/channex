module Channex
  module Resources
    # Restrictions API resource
    #
    # Restrictions represent pricing and stay restrictions applied to rate plans.
    # This includes rates, min/max stay, closed to arrival/departure, and stop sell.
    #
    # @example Get restrictions for a property
    #   client.restrictions.list(
    #     property_id: "property-uuid",
    #     date_from: "2024-01-01",
    #     date_to: "2024-01-31"
    #   )
    #
    # @example Update restrictions (rates and stay rules)
    #   client.restrictions.update([
    #     {
    #       property_id: "property-uuid",
    #       rate_plan_id: "rate-plan-uuid",
    #       date_from: "2024-01-15",
    #       date_to: "2024-01-20",
    #       rate: 15000,
    #       min_stay_arrival: 2,
    #       closed_to_arrival: false
    #     }
    #   ])
    #
    # @see https://docs.channex.io/api-v.1-documentation/ari
    #
    class Restrictions < Resource
      # Get restrictions for a property within a date range
      #
      # @param property_id [String] Property UUID (required)
      # @param date [String] Specific date (YYYY-MM-DD)
      # @param date_from [String] Start date (YYYY-MM-DD)
      # @param date_to [String] End date (YYYY-MM-DD)
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

      # Update restrictions (rates and stay rules) for rate plans
      #
      # Each value in the array should contain all required fields including property_id.
      # You can update multiple properties and rate plans in a single request.
      #
      # @param values [Array<Hash>] Array of restriction updates
      #   Each hash can contain:
      #   - property_id [String] Property UUID (required)
      #   - rate_plan_id [String] Rate Plan UUID (required)
      #   - date_from [String] Start date YYYY-MM-DD (required)
      #   - date_to [String] End date YYYY-MM-DD (required)
      #   - rate [Integer] Price (in smallest currency unit, e.g., cents)
      #   - min_stay_arrival [Integer] Minimum stay if arriving on this date
      #   - min_stay_through [Integer] Minimum stay passing through this date
      #   - max_stay [Integer] Maximum stay (0 = no limit)
      #   - closed_to_arrival [Boolean] Prevent arrivals on this date
      #   - closed_to_departure [Boolean] Prevent departures on this date
      #   - stop_sell [Boolean] Stop selling this rate plan
      # @return [Response]
      #
      # @example Update rates and restrictions for a date range
      #   client.restrictions.update([
      #     {
      #       property_id: "716305c4-561a-4561-a187-7f5b8aeb5920",
      #       rate_plan_id: "bab451e7-9ab1-4cc4-aa16-107bf7bbabb2",
      #       date_from: "2024-01-15",
      #       date_to: "2024-01-20",
      #       rate: 30000,
      #       min_stay_arrival: 2,
      #       closed_to_arrival: false,
      #       stop_sell: false
      #     }
      #   ])
      def update(values)
        client.post(resource_path, body: {values: values})
      end

      protected

      def resource_path
        "/restrictions"
      end
    end
  end
end
