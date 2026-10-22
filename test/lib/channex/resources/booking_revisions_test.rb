require "test_helper"

class Channex::Resources::BookingRevisionsTest < ActiveSupport::TestCase
  setup do
    @channex = fake_channex
    @booking_revisions = Channex::Client.new.booking_revisions
  end

  test "list filters by booking and returns the revisions as typed objects" do
    @channex.add("booking_revisions", "rev-1", booking_id: "book-1", status: "new")

    response = @booking_revisions.list(booking_id: "book-1", order: {inserted_at: :asc}, limit: 100)

    request = @channex.sent(:get, "/booking_revisions").sole
    assert_equal({"booking_id" => "book-1"}, request.params["filter"])
    assert_equal({"inserted_at" => "asc"}, request.params["order"])
    assert_instance_of Channex::Objects::BookingRevision, response.objects.sole
    assert_equal "book-1", response.objects.sole.booking_id
  end
end
