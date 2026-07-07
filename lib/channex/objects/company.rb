module Channex
  module Objects
    # Company information nested within Customer
    #
    # @example
    #   company.title        # => "Acme Corp"
    #   company.number       # => "12345678"
    #   company.number_type  # => "vat"
    #
    class Company < Channex::Object
      attribute :title
      attribute :number
      attribute :number_type
    end
  end
end
