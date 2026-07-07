require "test_helper"

class Channex::Objects::TaxTest < ActiveSupport::TestCase
  setup do
    @data = {
      "type" => "Value Added Tax (VAT)",
      "name" => "VAT (12%)",
      "total_price" => "1311.43",
      "price_per_unit" => "1311.43",
      "price_mode" => "Per booking",
      "persons" => 2,
      "nights" => 4,
      "is_inclusive" => true
    }
  end

  # Core attributes
  test "provides typed access to type" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal "Value Added Tax (VAT)", tax.type
  end

  test "provides typed access to name" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal "VAT (12%)", tax.name
  end

  test "provides typed access to total_price" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal "1311.43", tax.total_price
  end

  test "provides typed access to price_per_unit" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal "1311.43", tax.price_per_unit
  end

  test "provides typed access to price_mode" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal "Per booking", tax.price_mode
  end

  test "provides typed access to persons" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal 2, tax.persons
  end

  test "provides typed access to nights" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal 4, tax.nights
  end

  # Inclusive flag — Channex sends this as `is_inclusive`
  test "provides typed access to inclusive via is_inclusive key" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal true, tax.inclusive
  end

  test "inclusive? returns true when is_inclusive is true" do
    tax = Channex::Objects::Tax.new(@data.merge("is_inclusive" => true))

    assert tax.inclusive?
  end

  test "inclusive? returns false when is_inclusive is false" do
    tax = Channex::Objects::Tax.new(@data.merge("is_inclusive" => false))

    assert_not tax.inclusive?
  end

  test "inclusive? returns false when is_inclusive is nil" do
    tax = Channex::Objects::Tax.new(@data.merge("is_inclusive" => nil))

    assert_not tax.inclusive?
  end

  test "inclusive? returns false when is_inclusive is missing" do
    tax = Channex::Objects::Tax.new(@data.except("is_inclusive"))

    assert_not tax.inclusive?
  end

  test "inclusive? returns false for truthy non-true values" do
    # Only exactly `true` should return true
    tax = Channex::Objects::Tax.new(@data.merge("is_inclusive" => "true"))

    assert_not tax.inclusive?
  end

  # Different tax types
  test "handles different tax types" do
    types = ["Value Added Tax (VAT)", "City Tax", "Tourist Tax", "Service Charge"]

    types.each do |type|
      tax = Channex::Objects::Tax.new(@data.merge("type" => type))
      assert_equal type, tax.type
    end
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal "VAT (12%)", tax["name"]
    assert_equal "1311.43", tax["total_price"]
    assert_equal true, tax["is_inclusive"]
  end

  test "to_h returns raw data" do
    tax = Channex::Objects::Tax.new(@data)

    assert_equal @data, tax.to_h
  end

  # Edge cases
  test "handles missing data gracefully" do
    tax = Channex::Objects::Tax.new({})

    assert_nil tax.type
    assert_nil tax.name
    assert_nil tax.total_price
    assert_nil tax.price_per_unit
    assert_nil tax.price_mode
    assert_nil tax.persons
    assert_nil tax.nights
    assert_nil tax.inclusive
    assert_not tax.inclusive?
  end

  test "handles zero total_price" do
    tax = Channex::Objects::Tax.new(@data.merge("total_price" => "0.00"))

    assert_equal "0.00", tax.total_price
  end
end
