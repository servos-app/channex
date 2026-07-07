module Channex
  module Objects
    # Individual guest information within a room
    #
    # @example
    #   guest.name       # => "John"
    #   guest.surname    # => "Doe"
    #   guest.full_name  # => "John Doe"
    #
    class Guest < Channex::Object
      attribute :name
      attribute :surname

      # Combined first and last name
      # @return [String, nil]
      def full_name
        [name, surname].compact.join(" ").presence
      end
    end
  end
end
