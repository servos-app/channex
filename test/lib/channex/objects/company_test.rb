require "test_helper"

class Channex::Objects::CompanyTest < ActiveSupport::TestCase
  setup do
    @data = {
      "title" => "Acme Corporation",
      "number" => "VAT123456789",
      "number_type" => "vat"
    }
  end

  # Core attributes
  test "provides typed access to title" do
    company = Channex::Objects::Company.new(@data)

    assert_equal "Acme Corporation", company.title
  end

  test "provides typed access to number" do
    company = Channex::Objects::Company.new(@data)

    assert_equal "VAT123456789", company.number
  end

  test "provides typed access to number_type" do
    company = Channex::Objects::Company.new(@data)

    assert_equal "vat", company.number_type
  end

  # Different number types
  test "handles vat number type" do
    company = Channex::Objects::Company.new(@data.merge("number_type" => "vat"))

    assert_equal "vat", company.number_type
  end

  test "handles tax_id number type" do
    company = Channex::Objects::Company.new(@data.merge("number_type" => "tax_id"))

    assert_equal "tax_id", company.number_type
  end

  test "handles registration number type" do
    company = Channex::Objects::Company.new(@data.merge("number_type" => "registration"))

    assert_equal "registration", company.number_type
  end

  test "handles ein number type" do
    company = Channex::Objects::Company.new(@data.merge("number_type" => "ein"))

    assert_equal "ein", company.number_type
  end

  # Different company titles
  test "handles various company titles" do
    titles = [
      "Acme Corp",
      "Acme Corporation Ltd.",
      "Acme GmbH",
      "株式会社アクメ",
      "Société Acme S.A."
    ]

    titles.each do |title|
      company = Channex::Objects::Company.new(@data.merge("title" => title))
      assert_equal title, company.title
    end
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    company = Channex::Objects::Company.new(@data)

    assert_equal "Acme Corporation", company["title"]
    assert_equal "VAT123456789", company["number"]
  end

  test "to_h returns raw data" do
    company = Channex::Objects::Company.new(@data)

    assert_equal @data, company.to_h
  end

  # Edge cases
  test "handles missing data gracefully" do
    company = Channex::Objects::Company.new({})

    assert_nil company.title
    assert_nil company.number
    assert_nil company.number_type
  end

  test "handles company with only title" do
    company = Channex::Objects::Company.new({"title" => "Anonymous Corp"})

    assert_equal "Anonymous Corp", company.title
    assert_nil company.number
    assert_nil company.number_type
  end

  test "handles empty strings" do
    company = Channex::Objects::Company.new({
      "title" => "",
      "number" => "",
      "number_type" => ""
    })

    assert_equal "", company.title
    assert_equal "", company.number
    assert_equal "", company.number_type
  end

  test "handles nil values" do
    company = Channex::Objects::Company.new({
      "title" => nil,
      "number" => nil,
      "number_type" => nil
    })

    assert_nil company.title
    assert_nil company.number
    assert_nil company.number_type
  end
end
