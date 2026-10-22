require "test_helper"

class Channex::Resources::AttachmentsTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @attachments = Channex::Resources::Attachments.new(@client)
  end

  test "create wraps the file in an attachment key" do
    @client.expects(:post).with(
      "/attachments",
      body: {attachment: {file: "YmFzZTY0", file_name: "photo.jpeg", file_type: "image/jpeg"}}
    ).returns(mock("response"))

    @attachments.create(file: "YmFzZTY0", file_name: "photo.jpeg", file_type: "image/jpeg")
  end
end
