require "test_helper"

class Channex::Objects::OccupancyTest < ActiveSupport::TestCase
  setup do
    @data = {
      "adults" => 2,
      "children" => 1,
      "infants" => 1,
      "ages" => [8, 2]
    }
  end

  # Core attributes
  test "provides typed access to adults" do
    occupancy = Channex::Objects::Occupancy.new(@data)

    assert_equal 2, occupancy.adults
  end

  test "provides typed access to children" do
    occupancy = Channex::Objects::Occupancy.new(@data)

    assert_equal 1, occupancy.children
  end

  test "provides typed access to infants" do
    occupancy = Channex::Objects::Occupancy.new(@data)

    assert_equal 1, occupancy.infants
  end

  # Ages
  test "ages returns array of child ages" do
    occupancy = Channex::Objects::Occupancy.new(@data)

    assert_equal [8, 2], occupancy.ages
  end

  test "ages returns empty array when not present" do
    occupancy = Channex::Objects::Occupancy.new({})

    assert_equal [], occupancy.ages
  end

  # Total guests
  test "total_guests sums adults, children, and infants" do
    occupancy = Channex::Objects::Occupancy.new(@data)

    assert_equal 4, occupancy.total_guests
  end

  test "total_guests handles missing adults" do
    occupancy = Channex::Objects::Occupancy.new({"children" => 2, "infants" => 1})

    assert_equal 3, occupancy.total_guests
  end

  test "total_guests handles missing children" do
    occupancy = Channex::Objects::Occupancy.new({"adults" => 2, "infants" => 1})

    assert_equal 3, occupancy.total_guests
  end

  test "total_guests handles missing infants" do
    occupancy = Channex::Objects::Occupancy.new({"adults" => 2, "children" => 1})

    assert_equal 3, occupancy.total_guests
  end

  test "total_guests returns 0 when all are missing" do
    occupancy = Channex::Objects::Occupancy.new({})

    assert_equal 0, occupancy.total_guests
  end

  test "total_guests handles nil values" do
    occupancy = Channex::Objects::Occupancy.new({
      "adults" => nil,
      "children" => nil,
      "infants" => nil
    })

    assert_equal 0, occupancy.total_guests
  end

  test "total_guests with only adults" do
    occupancy = Channex::Objects::Occupancy.new({"adults" => 3})

    assert_equal 3, occupancy.total_guests
  end

  test "total_guests with zero values" do
    occupancy = Channex::Objects::Occupancy.new({
      "adults" => 2,
      "children" => 0,
      "infants" => 0
    })

    assert_equal 2, occupancy.total_guests
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    occupancy = Channex::Objects::Occupancy.new(@data)

    assert_equal 2, occupancy["adults"]
  end

  test "to_h returns raw data" do
    occupancy = Channex::Objects::Occupancy.new(@data)

    assert_equal @data, occupancy.to_h
  end

  # Edge cases
  test "handles missing data gracefully" do
    occupancy = Channex::Objects::Occupancy.new({})

    assert_nil occupancy.adults
    assert_nil occupancy.children
    assert_nil occupancy.infants
    assert_equal [], occupancy.ages
    assert_equal 0, occupancy.total_guests
  end
end
