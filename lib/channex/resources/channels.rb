module Channex
  module Resources
    # Channels API resource
    #
    # Channels represent connections to OTAs (Online Travel Agencies) like
    # Booking.com, Airbnb, Expedia, etc.
    #
    # @example List channels for a property
    #   client.channels.list(property_id: "property-uuid")
    #
    # @example Retrieve a channel
    #   client.channels.retrieve("channel-uuid")
    #
    # @see https://docs.channex.io/api-v.1-documentation/channel-api
    #
    class Channels < Resource
      # Get list of available channel codes/types
      #
      # @return [Response]
      def codes
        client.get("/channel_codes")
      end

      # Test OTA credentials before connecting. Returns the OTA's acknowledgement
      # that the hotel_id + channel are reachable. The first call also reveals
      # whether the account has Channel API access.
      #
      # @param channel [String] OTA code (e.g. "BookingCom")
      # @param settings [Hash] OTA settings, at least { hotel_id: "..." }
      # @return [Response]
      def test_connection(channel:, settings:)
        client.post("#{resource_path}/test_connection", body: {channel:, settings:})
      end

      # Fetch the OTA's rooms and rates to map against local rate plans. For
      # Booking.com this returns rooms[].rates[], each keyed by an integer code.
      #
      # @param channel [String] OTA code (e.g. "BookingCom")
      # @param settings [Hash] OTA settings, at least { hotel_id: "..." }
      # @return [Response]
      def mapping_details(channel:, settings:)
        client.post("#{resource_path}/mapping_details", body: {channel:, settings:})
      end

      # Connect a new channel to a property
      #
      # @param attributes [Hash] Channel attributes including property_id, channel code, credentials
      # @return [Response]
      def connect(attributes)
        create(attributes)
      end

      # Channels are created inactive; activate to go live.
      #
      # @param id [String] Channel UUID
      # @return [Response]
      def activate(id)
        client.post("#{resource_path}/#{id}/activate", body: {})
      end

      # Pause a live channel without deleting it.
      #
      # @param id [String] Channel UUID
      # @return [Response]
      def deactivate(id)
        client.post("#{resource_path}/#{id}/deactivate", body: {})
      end

      # Disconnect a channel (must be inactive first)
      #
      # @param id [String] Channel UUID
      # @return [Response]
      def disconnect(id)
        delete(id)
      end

      # Full sync a channel (refresh all data from OTA)
      #
      # @param id [String] Channel UUID
      # @return [Response]
      def full_sync(id)
        client.post("#{resource_path}/#{id}/full_sync", body: {})
      end

      protected

      def resource_path
        "/channels"
      end

      def filter_keys
        %i[property_id]
      end
    end
  end
end
