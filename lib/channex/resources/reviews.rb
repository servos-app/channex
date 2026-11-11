module Channex
  module Resources
    # Reviews API resource
    #
    # A review is what a guest wrote about a stay on Booking.com, Airbnb or
    # Expedia, normalised by Channex: an overall score out of 10, per-category
    # scores, the text and the property's reply.
    #
    # Requires the Messages & Reviews application to be installed on the
    # property — without it every call in here answers 403 Forbidden.
    #
    # @example List a property's reviews
    #   client.reviews.list(property_id: "property-uuid")
    #
    # @example Reply to a review
    #   client.reviews.reply("review-uuid", reply: "Thank you for staying with us.")
    #
    # @see https://docs.channex.io/api-v.1-documentation/reviews-collection
    #
    class Reviews < Resource
      # Reply to a review on the OTA
      #
      # @param id [String] Review UUID
      # @param reply [String] Reply text
      # @return [Response] The review, now replied
      def reply(id, reply:)
        client.post("#{resource_path}/#{id}/reply", body: {reply: {reply:}})
      end

      protected

      def resource_path
        "/reviews"
      end

      def filter_keys
        %i[property_id booking_id]
      end
    end
  end
end
