module Channex
  module Objects
    # A conversation between a guest and the property, as Channex unifies it
    # across Booking.com, Airbnb and Expedia.
    #
    # Like {Message}, a thread arrives as a JSON:API resource node;
    # {.from_resource} flattens the identifier and relationships into the
    # attributes so the whole thread is one hash.
    #
    # A thread usually belongs to a booking, but not always: an Airbnb inquiry
    # is a conversation about a stay that does not exist yet, so `booking_id`
    # is nil until the guest books.
    #
    # @example
    #   thread.title        # => "Maldonado Roxy"
    #   thread.provider     # => "BookingCom"
    #   thread.closed?      # => false
    #   thread.last_message # => Channex::Objects::Message
    #
    class MessageThread < Channex::Object
      attribute :id
      attribute :title
      attribute :provider
      attribute :message_count
      attribute :last_message, type: Message
      attribute :last_message_received_at
      attribute :inserted_at
      attribute :updated_at

      # Lifted out of `relationships`
      attribute :booking_id
      attribute :channel_id
      attribute :property_id

      # Flatten a JSON:API resource node into a thread
      #
      # @param node [Hash, nil] A `{"id", "attributes", "relationships"}` node
      # @return [MessageThread, nil]
      def self.from_resource(node)
        return nil if node.nil?

        attributes = node["attributes"] || {}
        relationships = node["relationships"] || {}

        new(
          attributes.merge(
            "id" => node["id"],
            "booking_id" => relationships.dig("booking", "data", "id"),
            "channel_id" => relationships.dig("channel", "data", "id"),
            "property_id" => relationships.dig("property", "data", "id")
          ).compact
        )
      end

      # Whether the property closed the thread. Closed threads still accept
      # messages; the flag is an inbox state, not a lock.
      #
      # @return [Boolean]
      def closed?
        @data["is_closed"] == true
      end

      # @return [Boolean]
      def open?
        !closed?
      end

      # Whether the thread hangs off a booking. Airbnb inquiries do not.
      #
      # @return [Boolean]
      def booking?
        !booking_id.nil?
      end
    end
  end
end
