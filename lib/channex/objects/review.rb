module Channex
  module Objects
    # A guest's review of a stay, as Channex unifies it across Booking.com,
    # Airbnb and Expedia.
    #
    # Like {MessageThread}, a review arrives as a JSON:API resource node;
    # {.from_resource} flattens the identifier and relationships into the
    # attributes so the whole review is one hash.
    #
    # Scores are out of 10 whatever the OTA rates on; `scores` holds one
    # `{"category", "score"}` pair per category the OTA asks about, named in
    # the OTA's own vocabulary (`clean` on Booking.com, `cleanliness` on Airbnb).
    #
    # @example
    #   review.ota           # => "BookingCom"
    #   review.overall_score # => 9.0
    #   review.scores        # => [{"category" => "clean", "score" => 10}]
    #   review.replied?      # => false
    #
    class Review < Channex::Object
      attribute :id
      attribute :content
      attribute :guest_name
      attribute :ota
      attribute :ota_reservation_id
      attribute :overall_score
      attribute :reply
      attribute :received_at
      attribute :inserted_at
      attribute :updated_at

      # Lifted out of `relationships`
      attribute :booking_id
      attribute :channel_id
      attribute :property_id

      # Flatten a JSON:API resource node into a review
      #
      # @param node [Hash, nil] A `{"id", "attributes", "relationships"}` node
      # @return [Review, nil]
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

      # Per-category scores, `{"category", "score"}` pairs
      #
      # @return [Array<Hash>]
      def scores
        @data["scores"] || []
      end

      # Review tag codes (Airbnb only)
      #
      # @return [Array<String>]
      def tags
        @data["tags"] || []
      end

      # Whether the property has replied
      #
      # @return [Boolean]
      def replied?
        @data["is_replied"] == true
      end

      # Whether Airbnb is holding the review back until the host reviews the
      # guest in turn (Airbnb only)
      #
      # @return [Boolean]
      def hidden?
        @data["is_hidden"] == true
      end
    end
  end
end
