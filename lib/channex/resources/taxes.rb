module Channex
  module Resources
    # Taxes API resource
    #
    # A Tax represents a specific tax applicable to your Rate Plan or Property,
    # such as VAT 20%, City Tax 1 EUR per Guest per Night, etc.
    #
    # @example List taxes for a property
    #   client.taxes.list(property_id: "property-uuid")
    #
    # @example Create a percentage-based tax (VAT)
    #   client.taxes.create(
    #     property_id: "property-uuid",
    #     title: "VAT",
    #     logic: "percent",
    #     type: "tax",
    #     rate: "20.00",
    #     is_inclusive: true
    #   )
    #
    # @example Create a fixed amount tax (City Tax per person per night)
    #   client.taxes.create(
    #     property_id: "property-uuid",
    #     title: "City Tax",
    #     logic: "per_person_per_night",
    #     type: "city tax",
    #     rate: "2.00",
    #     currency: "EUR",
    #     is_inclusive: false
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/taxes-and-tax-sets
    #
    class Taxes < Resource
      # Logic types for tax calculation
      LOGIC_TYPES = %w[
        percent
        per_room
        per_room_per_night
        per_person
        per_person_per_night
        per_night
        per_booking
      ].freeze

      # Tax types
      TAX_TYPES = ["tax", "fee", "city tax"].freeze

      # List taxes with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      # Create a new tax
      #
      # @param attributes [Hash] Tax attributes
      #   - property_id [String] Property UUID (required)
      #   - title [String] Tax name, max 255 chars (required)
      #   - logic [String] Calculation method (required): "percent", "per_room",
      #     "per_room_per_night", "per_person", "per_person_per_night", "per_night", "per_booking"
      #   - type [String] Tax type (required): "tax", "fee", "city tax"
      #   - rate [String] Tax amount/percentage (required). For percent: 0-100. For others: fixed amount.
      #   - is_inclusive [Boolean] Include in room price or add on top (required)
      #   - currency [String] Currency code, required if logic is not "percent"
      #   - skip_nights [Integer] Days to skip before applying tax (optional)
      #   - max_nights [Integer] Max days to apply tax (optional)
      #   - applicable_date_ranges [Array<Hash>] Date ranges when tax applies (optional)
      #     Each hash: { after: "2024-01-01", before: "2024-12-31" }
      # @return [Response]
      def create(attributes)
        client.post(resource_path, body: {tax: attributes})
      end

      # Update a tax
      #
      # @param id [String] Tax UUID
      # @param attributes [Hash] Tax attributes to update
      # @return [Response]
      def update(id, attributes)
        client.put("#{resource_path}/#{id}", body: {tax: attributes})
      end

      protected

      def resource_path
        "/taxes"
      end

      def resource_name
        "tax"
      end
    end
  end
end
