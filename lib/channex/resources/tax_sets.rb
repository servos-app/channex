module Channex
  module Resources
    # Tax Sets API resource
    #
    # A Tax Set represents a group of Taxes applicable to your Rate Plan or Property.
    # Each property can have many Tax Sets, but only one can be selected as
    # the Default Tax Set, which is applied to each new Rate Plan automatically.
    #
    # @example List tax sets for a property
    #   client.tax_sets.list(property_id: "property-uuid")
    #
    # @example Create a tax set
    #   client.tax_sets.create(
    #     property_id: "property-uuid",
    #     title: "Standard Taxes",
    #     taxes: ["tax-uuid-1", "tax-uuid-2"],
    #     is_default: true
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/taxes-and-tax-sets
    #
    class TaxSets < Resource
      protected

      def resource_path
        "/tax_sets"
      end

      def filter_keys
        %i[property_id]
      end
    end
  end
end
