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
      # List tax sets with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      protected

      def resource_path
        "/tax_sets"
      end

      def resource_name
        "tax_set"
      end
    end
  end
end
