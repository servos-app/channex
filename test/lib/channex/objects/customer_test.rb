require "test_helper"

class Channex::Objects::CustomerTest < ActiveSupport::TestCase
  setup do
    @data = {
      "name" => "John",
      "surname" => "Doe",
      "mail" => "john@example.com",
      "phone" => "+1234567890",
      "country" => "US",
      "city" => "New York",
      "address" => "123 Main St",
      "zip" => "10001",
      "language" => "en",
      "company" => {
        "title" => "Acme Corp",
        "number" => "VAT123",
        "number_type" => "vat"
      },
      "meta" => {
        "loyalty_id" => "GOLD-12345"
      }
    }
  end

  # Core attributes
  test "provides typed access to name fields" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "John", customer.name
    assert_equal "Doe", customer.surname
  end

  test "provides typed access to contact information" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "john@example.com", customer.mail
    assert_equal "+1234567890", customer.phone
  end

  test "provides typed access to address information" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "US", customer.country
    assert_equal "New York", customer.city
    assert_equal "123 Main St", customer.address
    assert_equal "10001", customer.zip
  end

  test "provides typed access to language" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "en", customer.language
  end

  # Email alias
  test "email is an alias for mail" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "john@example.com", customer.email
    assert_equal customer.mail, customer.email
  end

  test "email returns nil when mail is missing" do
    customer = Channex::Objects::Customer.new({})

    assert_nil customer.email
  end

  # Full name
  test "full_name combines name and surname" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "John Doe", customer.full_name
  end

  test "full_name returns only name when surname is missing" do
    customer = Channex::Objects::Customer.new({"name" => "John"})

    assert_equal "John", customer.full_name
  end

  test "full_name returns only surname when name is missing" do
    customer = Channex::Objects::Customer.new({"surname" => "Doe"})

    assert_equal "Doe", customer.full_name
  end

  test "full_name returns nil when both name and surname are missing" do
    customer = Channex::Objects::Customer.new({})

    assert_nil customer.full_name
  end

  test "full_name returns nil when both are empty strings" do
    customer = Channex::Objects::Customer.new({"name" => "", "surname" => ""})

    assert_nil customer.full_name
  end

  test "full_name trims whitespace correctly" do
    customer = Channex::Objects::Customer.new({"name" => "John", "surname" => nil})

    assert_equal "John", customer.full_name
  end

  # Company (nested)
  test "company is wrapped in Company object" do
    customer = Channex::Objects::Customer.new(@data)

    assert_instance_of Channex::Objects::Company, customer.company
    assert_equal "Acme Corp", customer.company.title
    assert_equal "VAT123", customer.company.number
    assert_equal "vat", customer.company.number_type
  end

  test "company returns nil when not present" do
    customer = Channex::Objects::Customer.new({})

    assert_nil customer.company
  end

  # Meta
  test "meta returns metadata hash" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "GOLD-12345", customer.meta["loyalty_id"]
  end

  test "meta returns empty hash when not present" do
    customer = Channex::Objects::Customer.new({})

    assert_equal({}, customer.meta)
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal "John", customer["name"]
    assert_equal "Acme Corp", customer.dig("company", "title")
  end

  test "to_h returns raw data" do
    customer = Channex::Objects::Customer.new(@data)

    assert_equal @data, customer.to_h
  end

  # Edge cases
  test "handles missing data gracefully" do
    customer = Channex::Objects::Customer.new({})

    assert_nil customer.name
    assert_nil customer.surname
    assert_nil customer.mail
    assert_nil customer.email
    assert_nil customer.phone
    assert_nil customer.country
    assert_nil customer.city
    assert_nil customer.address
    assert_nil customer.zip
    assert_nil customer.language
    assert_nil customer.company
    assert_nil customer.full_name
    assert_equal({}, customer.meta)
  end

  test "handles whitespace in name fields" do
    customer = Channex::Objects::Customer.new({
      "name" => "  John  ",
      "surname" => "  Doe  "
    })

    # Attributes return raw values
    assert_equal "  John  ", customer.name
    assert_equal "  Doe  ", customer.surname
    # full_name joins them but doesn't strip
    assert_equal "  John     Doe  ", customer.full_name
  end
end
