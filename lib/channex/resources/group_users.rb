module Channex
  module Resources
    # Group Users API resource
    #
    # Group Users represent the association between users and groups,
    # defining access permissions. By inviting a User into a Group, you
    # automatically grant access for this user to all properties in the Group.
    #
    # @example List users in a group
    #   client.group_users.list(group_id: "group-uuid")
    #
    # @example Invite a user to a group
    #   client.group_users.invite(
    #     group_id: "group-uuid",
    #     user_email: "user@example.com",
    #     role: "user"
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/group-users-collection
    #
    class GroupUsers < Resource
      ROLES = %w[owner user].freeze

      # Invite a user to a group
      #
      # If the user is not registered, Channex will create their account
      # automatically and send an email with instructions to onboard.
      #
      # @param group_id [String] Group UUID (required)
      # @param user_email [String] Email address of the user to invite (required)
      # @param role [String] Role: "owner" or "user" (required)
      # @param overrides [Hash] Access policies overrides (optional)
      # @return [Response]
      #
      # @example Invite a user with default permissions
      #   client.group_users.invite(
      #     group_id: "52397a6e-c330-44f4-a293-47042d3a3607",
      #     user_email: "other_user@channex.io",
      #     role: "user"
      #   )
      def invite(group_id:, user_email:, role:, overrides: {})
        client.post(resource_path, body: {
          invite: {
            group_id: group_id,
            user_email: user_email,
            role: role,
            overrides: overrides
          }
        })
      end

      # @see #invite
      def create(attributes)
        invite(**attributes)
      end

      # Revoke a user's access to a group
      #
      # @param id [String] Group User UUID
      # @return [Response]
      def revoke(id)
        delete(id)
      end

      protected

      def resource_path
        "/group_users"
      end

      def filter_keys
        %i[group_id]
      end
    end
  end
end
