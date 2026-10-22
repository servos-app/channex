module Channex
  module Resources
    # Hotel Policies API resource
    #
    # Hotel Policies contain property-level settings like check-in/check-out times,
    # internet access, parking, pets policy, and smoking rules.
    #
    # @example List hotel policies for a property
    #   client.hotel_policies.list(property_id: "property-uuid")
    #
    # @example Create a hotel policy
    #   client.hotel_policies.create(
    #     property_id: "property-uuid",
    #     title: "Standard Policy",
    #     currency: "USD",
    #     checkin_time: "15:00",
    #     checkout_time: "11:00",
    #     pets_policy: "not_allowed",
    #     smoking_policy: "no_smoking"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/hotel-policy-collection
    #
    class HotelPolicies < Resource
      # Pets policy options
      PETS_POLICIES = %w[allowed not_allowed by_arrangements pets_not_allowed_on_beds].freeze

      # Smoking policy options
      SMOKING_POLICIES = %w[no_smoking smoking_allowed designated_areas].freeze

      # Internet access type options
      INTERNET_ACCESS_TYPES = %w[wifi wired none].freeze

      # Internet access coverage options
      INTERNET_ACCESS_COVERAGES = %w[entire_property public_areas some_rooms all_rooms].freeze

      # Parking type options
      PARKING_TYPES = %w[on_site off_site none].freeze

      # Parking reservation options
      PARKING_RESERVATIONS = %w[needed not_needed not_available].freeze

      protected

      def resource_path
        "/hotel_policies"
      end

      def filter_keys
        %i[property_id]
      end
    end
  end
end
