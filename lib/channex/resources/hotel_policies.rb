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

      # List hotel policies with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      # Create a new hotel policy
      #
      # @param attributes [Hash] Hotel policy attributes
      #   - property_id [String] Property UUID (required)
      #   - title [String] Policy name (required)
      #   - currency [String] Currency code (required)
      #   - checkin_time [String] Check-in time in HH:MM format (e.g., "14:00")
      #   - checkout_time [String] Check-out time in HH:MM format (e.g., "11:00")
      #   - is_adults_only [Boolean] Adults only property
      #   - max_count_of_guests [Integer] Maximum guests allowed
      #   - internet_access_type [String] "wifi", "wired", or "none"
      #   - internet_access_cost [String] Cost or nil for free
      #   - internet_access_coverage [String] Coverage area
      #   - parking_type [String] "on_site", "off_site", or "none"
      #   - parking_reservation [String] "needed", "not_needed", or "not_available"
      #   - parking_is_private [Boolean] Private parking
      #   - pets_policy [String] "allowed", "not_allowed", "by_arrangements", "pets_not_allowed_on_beds"
      #   - pets_non_refundable_fee [String] Fee amount
      #   - pets_refundable_deposit [String] Deposit amount
      #   - smoking_policy [String] "no_smoking", "smoking_allowed", "designated_areas"
      # @return [Response]
      def create(attributes)
        client.post(resource_path, body: {hotel_policy: attributes})
      end

      # Update a hotel policy
      #
      # @param id [String] Hotel Policy UUID
      # @param attributes [Hash] Hotel policy attributes to update
      # @return [Response]
      def update(id, attributes)
        client.put("#{resource_path}/#{id}", body: {hotel_policy: attributes})
      end

      protected

      def resource_path
        "/hotel_policies"
      end

      def resource_name
        "hotel_policy"
      end
    end
  end
end
