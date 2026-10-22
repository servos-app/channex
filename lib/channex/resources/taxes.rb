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

      protected

      def resource_path
        "/taxes"
      end

      def filter_keys
        %i[property_id]
      end
    end
  end
end
