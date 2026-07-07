module Channex
  module Objects
    # Payment guarantee/card information
    #
    # Note: Contains sensitive payment data. Handle with care.
    #
    # @example
    #   guarantee.card_type       # => "visa"
    #   guarantee.card_number     # => "4111111111111111"
    #   guarantee.cardholder_name # => "John Doe"
    #   guarantee.expiration_date # => "12/25"
    #
    class Guarantee < Channex::Object
      attribute :card_number
      attribute :card_type
      attribute :cardholder_name
      attribute :cvv
      attribute :expiration_date
    end
  end
end
