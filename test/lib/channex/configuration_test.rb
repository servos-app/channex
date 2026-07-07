require "test_helper"

class Channex::ConfigurationTest < ActiveSupport::TestCase
  test "has default values" do
    config = Channex::Configuration.new

    assert_nil config.api_key
    assert_equal :staging, config.environment
    assert_equal 30, config.timeout
    assert_equal 10, config.open_timeout
    assert_nil config.logger
  end

  test "environment can be set to valid values" do
    config = Channex::Configuration.new

    config.environment = :staging
    assert_equal :staging, config.environment

    config.environment = :production
    assert_equal :production, config.environment

    config.environment = :secure_staging
    assert_equal :secure_staging, config.environment

    config.environment = :secure_production
    assert_equal :secure_production, config.environment
  end

  test "environment accepts string values" do
    config = Channex::Configuration.new

    config.environment = "production"
    assert_equal :production, config.environment
  end

  test "environment raises error for invalid values" do
    config = Channex::Configuration.new

    assert_raises(ArgumentError) do
      config.environment = :invalid
    end
  end

  test "base_url returns correct URL for each environment" do
    config = Channex::Configuration.new

    config.environment = :staging
    assert_equal "https://staging.channex.io", config.base_url

    config.environment = :production
    assert_equal "https://app.channex.io", config.base_url

    config.environment = :secure_staging
    assert_equal "https://secure-staging.channex.io", config.base_url

    config.environment = :secure_production
    assert_equal "https://secure.channex.io", config.base_url
  end

  test "api_url returns base_url with /api/v1 suffix" do
    config = Channex::Configuration.new

    config.environment = :staging
    assert_equal "https://staging.channex.io/api/v1", config.api_url

    config.environment = :production
    assert_equal "https://app.channex.io/api/v1", config.api_url
  end

  test "ENVIRONMENTS constant contains all valid environments" do
    expected = {
      staging: "https://staging.channex.io",
      production: "https://app.channex.io",
      secure_staging: "https://secure-staging.channex.io",
      secure_production: "https://secure.channex.io"
    }

    assert_equal expected, Channex::Configuration::ENVIRONMENTS
  end
end
