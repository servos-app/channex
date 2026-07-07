module Channex
  module Resources
    # Groups API resource
    #
    # Groups are used to organize properties and control access.
    # Each property can have a Base Group assigned.
    #
    # @example List groups
    #   client.groups.list
    #
    # @example Create a group
    #   client.groups.create(
    #     title: "Europe Hotels"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/groups-collection
    #
    class Groups < Resource
      protected

      def resource_path
        "/groups"
      end
    end
  end
end
