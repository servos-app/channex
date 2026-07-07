require "test_helper"

class Channex::Resources::GroupUsersTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @group_users = Channex::Resources::GroupUsers.new(@client)
  end

  test "ROLES constant includes all roles" do
    assert_equal %w[owner user], Channex::Resources::GroupUsers::ROLES
  end

  test "list with group_id filter" do
    response = mock("response")

    @client.expects(:get).with("/group_users", params: {filter: {group_id: "group-123"}}).returns(response)

    @group_users.list(group_id: "group-123")
  end

  test "invite sends correct body structure" do
    response = mock("response")

    expected_body = {
      invite: {
        group_id: "group-123",
        user_email: "user@example.com",
        role: "user",
        overrides: {}
      }
    }

    @client.expects(:post).with("/group_users", body: expected_body).returns(response)

    @group_users.invite(
      group_id: "group-123",
      user_email: "user@example.com",
      role: "user"
    )
  end

  test "invite with overrides" do
    response = mock("response")

    expected_body = {
      invite: {
        group_id: "group-123",
        user_email: "admin@example.com",
        role: "owner",
        overrides: {can_manage_properties: true}
      }
    }

    @client.expects(:post).with("/group_users", body: expected_body).returns(response)

    @group_users.invite(
      group_id: "group-123",
      user_email: "admin@example.com",
      role: "owner",
      overrides: {can_manage_properties: true}
    )
  end

  test "update wraps attributes in group_user key" do
    response = mock("response")

    @client.expects(:put).with("/group_users/gu-123", body: {group_user: {role: "owner"}}).returns(response)

    @group_users.update("gu-123", role: "owner")
  end

  test "revoke calls delete" do
    response = mock("response")

    @client.expects(:delete).with("/group_users/gu-123").returns(response)

    @group_users.revoke("gu-123")
  end
end
