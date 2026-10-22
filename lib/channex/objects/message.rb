module Channex
  module Objects
    # A single message inside a Message Thread.
    #
    # The API returns messages as JSON:API resource nodes — the text lives under
    # `attributes`, the identifier under `id` and the owning thread under
    # `relationships`. {.from_resource} flattens that node so a message is one
    # hash you can read, store and re-wrap.
    #
    # @example
    #   message.sender       # => "guest"
    #   message.from_guest?  # => true
    #   message.message      # => "What time is check-in?"
    #   message.thread_id    # => "4e160f0b-016a-424a-a30d-a9f0a8b1cbaa"
    #
    class Message < Channex::Object
      # Who put the message on the thread. `system` marks messages Channex
      # generates itself, such as an Airbnb inquiry.
      SENDERS = %w[guest property system].freeze

      attribute :id
      attribute :message
      attribute :sender
      attribute :inserted_at
      attribute :updated_at

      # Lifted out of `relationships`
      attribute :thread_id
      attribute :user_id

      # Flatten a JSON:API resource node into a message
      #
      # @param node [Hash, nil] A `{"id", "attributes", "relationships"}` node
      # @return [Message, nil]
      def self.from_resource(node)
        return nil if node.nil?

        attributes = node["attributes"] || {}
        relationships = node["relationships"] || {}

        new(
          attributes.merge(
            "id" => node["id"],
            "thread_id" => relationships.dig("message_thread", "data", "id"),
            "user_id" => relationships.dig("user", "data", "id")
          ).compact
        )
      end

      # Attachments as returned by the API. Channex sends relative URLs, which
      # have to be prefixed with the API base URL to be fetched.
      #
      # @return [Array]
      def attachments
        @data["attachments"] || []
      end

      # Attachment URLs, whether the API sent bare strings or objects.
      #
      # @return [Array<String>]
      def attachment_urls
        attachments.filter_map do |attachment|
          attachment.is_a?(Hash) ? attachment["url"] : attachment
        end
      end

      # @return [Boolean]
      def attachments?
        !attachments.empty?
      end

      # Provider-specific extras, e.g. the booking details of an Airbnb inquiry.
      #
      # @return [Hash]
      def meta
        @data["meta"] || {}
      end

      # @return [Boolean]
      def from_guest?
        sender == "guest"
      end

      # @return [Boolean]
      def from_property?
        sender == "property"
      end

      # @return [Boolean]
      def from_system?
        sender == "system"
      end
    end
  end
end
