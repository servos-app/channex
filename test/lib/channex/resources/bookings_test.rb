require "test_helper"

class Channex::Resources::BookingsTest < ActiveSupport::TestCase
  setup do
    @channex = fake_channex
    @bookings = Channex::Client.new.bookings
  end

  test "list_all filters by property and by arrival date from date_from" do
    @bookings.list_all(property_id: "prop-1", date_from: "2026-10-01")

    assert_equal({"property_id" => "prop-1", "arrival_date" => {"gte" => "2026-10-01"}},
      @channex.sent(:get, "/bookings").sole.params["filter"])
  end

  test "list bounds the arrival date by date_from and date_to" do
    @bookings.list(date_from: "2026-10-01", date_to: "2026-10-31")

    assert_equal({"arrival_date" => {"gte" => "2026-10-01", "lte" => "2026-10-31"}},
      @channex.sent(:get, "/bookings").sole.params["filter"])
  end

  test "list without dates sends no arrival date filter" do
    @bookings.list(status: "new", channel_id: "chan-1")

    assert_equal({"status" => "new", "channel_id" => "chan-1"}, @channex.sent(:get, "/bookings").sole.params["filter"])
  end
end
