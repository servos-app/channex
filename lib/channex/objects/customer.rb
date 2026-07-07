module Channex
  module Objects
    # Customer information from a booking
    #
    # @example
    #   customer.name       # => "John"
    #   customer.surname    # => "Doe"
    #   customer.full_name  # => "John Doe"
    #   customer.email      # => "john@example.com"
    #   customer.company    # => Channex::Objects::Company
    #
    class Customer < Channex::Object
      attribute :name
      attribute :surname
      attribute :mail
      attribute :phone
      attribute :country
      attribute :city
      attribute :address
      attribute :zip
      attribute :language
      attribute :company, type: Company

      # Alias for mail (more intuitive name)
      # @return [String, nil]
      def email
        mail
      end

      # Combined first and last name
      # @return [String, nil]
      def full_name
        [name, surname].compact.join(" ").presence
      end

      # Free-form metadata
      # @return [Hash]
      def meta
        @data["meta"] || {}
      end
    end
  end
end
