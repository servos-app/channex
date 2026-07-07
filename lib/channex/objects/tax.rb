module Channex
  module Objects
    # Tax applied to a booking room.
    #
    # Channex represents taxes with the same shape as services: an amount
    # (`total_price` / `price_per_unit`), a `price_mode`, and an `is_inclusive`
    # flag indicating whether the tax is already baked into the room price.
    #
    # @see https://docs.channex.io/api-v.1-documentation/taxes-and-tax-sets
    #
    # @example
    #   tax.type           # => "Value Added Tax (VAT)"
    #   tax.name           # => "VAT (12%)"
    #   tax.total_price    # => "1311.43"
    #   tax.price_per_unit # => "1311.43"
    #   tax.price_mode     # => "Per booking"
    #   tax.inclusive?     # => true
    #
    class Tax < Channex::Object
      attribute :type
      attribute :name
      attribute :total_price
      attribute :price_per_unit
      attribute :price_mode
      attribute :persons
      attribute :nights
      attribute :inclusive, key: "is_inclusive"

      # Whether the tax is already included in the price
      # @return [Boolean]
      def inclusive?
        inclusive == true
      end
    end
  end
end
