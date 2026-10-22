# frozen_string_literal: true

require "channex"

require "minitest/autorun"
require "active_support"
require "active_support/test_case"
require "mocha/minitest"
require "webmock/minitest"
require "rack/utils"
require "securerandom"

TEST_API_KEY = "test-api-key"

WebMock.disable_net_connect!

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

class ActiveSupport::TestCase
  include FakeChannexApi
end
