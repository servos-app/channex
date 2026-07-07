require "test_helper"

class Channex::Objects::GuestTest < ActiveSupport::TestCase
  setup do
    @data = {
      "name" => "John",
      "surname" => "Doe"
    }
  end

  # Core attributes
  test "provides typed access to name" do
    guest = Channex::Objects::Guest.new(@data)

    assert_equal "John", guest.name
  end

  test "provides typed access to surname" do
    guest = Channex::Objects::Guest.new(@data)

    assert_equal "Doe", guest.surname
  end

  # Full name
  test "full_name combines name and surname" do
    guest = Channex::Objects::Guest.new(@data)

    assert_equal "John Doe", guest.full_name
  end

  test "full_name returns only name when surname is missing" do
    guest = Channex::Objects::Guest.new({"name" => "John"})

    assert_equal "John", guest.full_name
  end

  test "full_name returns only surname when name is missing" do
    guest = Channex::Objects::Guest.new({"surname" => "Doe"})

    assert_equal "Doe", guest.full_name
  end

  test "full_name returns nil when both name and surname are missing" do
    guest = Channex::Objects::Guest.new({})

    assert_nil guest.full_name
  end

  test "full_name returns nil when both are empty strings" do
    guest = Channex::Objects::Guest.new({"name" => "", "surname" => ""})

    assert_nil guest.full_name
  end

  test "full_name returns nil when both are nil" do
    guest = Channex::Objects::Guest.new({"name" => nil, "surname" => nil})

    assert_nil guest.full_name
  end

  test "full_name handles nil name with valid surname" do
    guest = Channex::Objects::Guest.new({"name" => nil, "surname" => "Doe"})

    assert_equal "Doe", guest.full_name
  end

  test "full_name handles valid name with nil surname" do
    guest = Channex::Objects::Guest.new({"name" => "John", "surname" => nil})

    assert_equal "John", guest.full_name
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    guest = Channex::Objects::Guest.new(@data)

    assert_equal "John", guest["name"]
    assert_equal "Doe", guest["surname"]
  end

  test "to_h returns raw data" do
    guest = Channex::Objects::Guest.new(@data)

    assert_equal @data, guest.to_h
  end

  # Edge cases
  test "handles missing data gracefully" do
    guest = Channex::Objects::Guest.new({})

    assert_nil guest.name
    assert_nil guest.surname
    assert_nil guest.full_name
  end

  test "handles names with special characters" do
    guest = Channex::Objects::Guest.new({
      "name" => "José",
      "surname" => "García"
    })

    assert_equal "José", guest.name
    assert_equal "García", guest.surname
    assert_equal "José García", guest.full_name
  end

  test "handles hyphenated names" do
    guest = Channex::Objects::Guest.new({
      "name" => "Mary-Jane",
      "surname" => "Watson-Parker"
    })

    assert_equal "Mary-Jane Watson-Parker", guest.full_name
  end
end
