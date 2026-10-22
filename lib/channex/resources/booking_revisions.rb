module Channex
  module Resources
    # Booking Revisions API resource
    #
    # Booking Revisions are snapshots of bookings at a given time.
    # Each time an OTA provides an update, a new revision is created.
    # The feed endpoint is the primary way to receive new bookings from Channex.
    #
    # IMPORTANT: You must acknowledge bookings after processing them.
    # Not acknowledging bookings will result in them being repeatedly
    # returned for 30 minutes, followed by email warnings.
    #
    # @example Get unacknowledged booking revisions (typed objects)
    #   response = client.booking_revisions.feed
    #   response.objects.each do |revision|
    #     puts revision.customer.full_name
    #     revision.rooms.each { |room| puts room.nights }
    #     client.booking_revisions.acknowledge(revision.id)
    #   end
    #
    # @example Hash access still works for backwards compatibility
    #   response = client.booking_revisions.feed
    #   response.data.each do |revision|
    #     puts revision["attributes"]["customer"]["name"]
    #   end
    #
    # @see https://docs.channex.io/api-v.1-documentation/bookings-collection
    #
    class BookingRevisions < Resource
      # Get unacknowledged booking revisions from the feed
      #
      # Returns a response with both raw data and typed objects.
      # Use response.objects for typed access, response.data for raw hashes.
      #
      # @param order [Hash] Ordering options (e.g., { inserted_at: :asc })
      # @return [Response] Response with #objects method for typed access
      def feed(order: {inserted_at: :asc})
        response = client.get("#{resource_path}/feed", params: {order: order})
        add_objects_wrapper(response)
        response
      end

      # Acknowledge a booking revision
      #
      # Once acknowledged, the revision will not appear in the feed again.
      #
      # @param id [String] Booking revision UUID
      # @return [Response]
      def acknowledge(id)
        client.post("#{resource_path}/#{id}/ack", body: {})
      end

      # Acknowledge multiple booking revisions at once
      #
      # @param ids [Array<String>] Array of booking revision UUIDs
      # @return [Array<Response>]
      def acknowledge_all(ids)
        ids.map { |id| acknowledge(id) }
      end

      # Retrieve a single booking revision
      #
      # Returns a response with both raw data and a typed object.
      # Use response.object for typed access, response.data for raw hash.
      #
      # @param id [String] Booking revision UUID
      # @return [Response] Response with #object method for typed access
      def retrieve(id)
        response = super
        add_object_wrapper(response)
        response
      end

      # List booking revisions, filtered by booking_id
      #
      # @return [Response] Response with #objects method for typed access
      def list(**)
        response = super
        add_objects_wrapper(response)
        response
      end

      protected

      def resource_path
        "/booking_revisions"
      end

      def filter_keys
        %i[booking_id]
      end

      private

      # Add #object method to response for single revision
      def add_object_wrapper(response)
        response.define_singleton_method(:object) do
          @_object ||= Channex::Objects::BookingRevision.construct_from(data&.dig("attributes"))
        end
      end

      # Add #objects method to response for multiple revisions
      def add_objects_wrapper(response)
        response.define_singleton_method(:objects) do
          @_objects ||= (data || []).map do |item|
            Channex::Objects::BookingRevision.construct_from(item["attributes"])
          end
        end
      end
    end
  end
end
