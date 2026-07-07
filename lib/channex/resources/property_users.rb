module Channex
  module Resources
    # Property Users API resource
    #
    # Property Users represent the association between users and properties,
    # defining access permissions at the property level.
    #
    # @example List users for a property
    #   client.property_users.list(property_id: "property-uuid")
    #
    # @example Add a user to a property
    #   client.property_users.create(
    #     property_id: "property-uuid",
    #     user_id: "user-uuid",
    #     role: "manager"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/property-users-collection
    #
    class PropertyUsers < Resource
      # List property users with optional filtering
      #
      # @param property_id [String] Filter by property UUID
      # @param options [Hash] Additional options
      # @return [Response]
      def list(property_id: nil, **options)
        filter = options.delete(:filter) || {}
        filter[:property_id] = property_id if property_id
        super(filter: filter, **options)
      end

      protected

      def resource_path
        "/property_users"
      end

      def resource_name
        "property_user"
      end
    end
  end
end
