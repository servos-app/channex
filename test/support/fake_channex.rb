# Serves a slice of Channex's HTTP API from WebMock, so Channex::Client runs
# as in production and only the round trip to channex.io is faked. Records come
# back in Channex's JSON:API shape, ARI pushes answer with a task and any
# warnings, and errors use Channex's `errors` body. An endpoint the fake doesn't
# serve fails the test, past any rescue in the code under test.
class FakeChannex
  Request = Data.define(:method, :path, :params, :body)

  API = %r{\Ahttps://[a-z-]+\.channex\.io/api/v1/}
  RESOURCES = {
    "properties" => "property",
    "room_types" => "room_type",
    "rate_plans" => "rate_plan",
    "channels" => "channel",
    "groups" => "group",
    "bookings" => "booking",
    "message_threads" => "message_thread",
    "booking_revisions" => "booking_revision"
  }.freeze
  ARI = %w[availability restrictions].freeze

  attr_reader :requests

  def initialize
    @store = Hash.new { |store, resource| store[resource] = {} }
    @acknowledged = Set.new
    @warnings = {}
    @requests = []
    @failure = nil
  end

  def install(test)
    test.stub_request(:any, API).to_return { |request| respond(request, URI(request.uri)) }
    self
  end

  def find(resource, id) = @store[resource].fetch(id)

  def all(resource) = @store[resource].values

  # A record that existed at Channex before the test began.
  def add(resource, id = SecureRandom.uuid, **attributes)
    @store[resource][id] = attributes.deep_stringify_keys.merge("id" => id)
  end

  def pushed(ari_endpoint) = sent(:post, "/#{ari_endpoint}").flat_map { |request| request.body["values"] }

  def sent(method, path) = requests.select { |request| request.method == method && request.path == path }

  # Channex accepts the next push to this ARI endpoint but rejects these values.
  def warn_on(resource, warnings)
    @warnings[resource.to_s] = warnings
  end

  # Runs while Channex answers the next request, as another process working meanwhile would.
  def meanwhile(&work)
    @meanwhile = work
  end

  def unreachable!
    @failure = ->(_) { raise Errno::ECONNREFUSED, "channex.io" }
  end

  def time_out!
    @failure = ->(_) { raise Net::OpenTimeout, "channex.io" }
  end

  # Every request from here on answers with this status and Channex error;
  # with `property:`, only the requests that push values for that property,
  # with `rate_plan:`, only those that push values for or update that rate
  # plan, and with `path:`, only the requests to that path.
  def fail_with!(status, title: "Something went wrong", property: nil, rate_plan: nil, path: nil, headers: {})
    @failure = lambda do |request|
      next if property && Array(request.body["values"]).none? { |value| value["property_id"] == property }
      next if rate_plan && !touches_rate_plan?(request, rate_plan)
      next if path && request.path != path

      [status, {"errors" => {"code" => "error", "title" => title}}, headers]
    end
  end

  private

  def touches_rate_plan?(request, rate_plan)
    request.path == "/rate_plans/#{rate_plan}" ||
      Array(request.body["values"]).any? { |value| value["rate_plan_id"] == rate_plan }
  end

  def respond(raw, uri)
    request = Request.new(method: raw.method, path: uri.path.delete_prefix("/api/v1").chomp("/"),
      params: Rack::Utils.parse_nested_query(uri.query), body: raw.body.present? ? JSON.parse(raw.body) : {})
    @requests << request
    work, @meanwhile = @meanwhile, nil
    work&.call

    status, payload, headers = @failure&.call(request) || route(request)
    {status:, body: payload.to_json, headers: {"Content-Type" => "application/json", **headers.to_h}}
  end

  def route(request)
    resource, id, action = request.path.delete_prefix("/").split("/", 3)
    return ari(request, resource) if ari?(resource, id)
    unserved(request) unless RESOURCES.key?(resource)
    return feed(resource) if id == "feed" && request.method == :get
    return collection(request, resource) || unserved(request) unless id

    record = @store[resource][id]
    return not_found unless record

    member(request, resource, record, action) || unserved(request)
  end

  def ari?(resource, id) = ARI.include?(resource) && id.nil?

  def ari(request, resource)
    (request.method == :post) ? push(resource) : unserved(request)
  end

  def collection(request, resource)
    case request.method
    when :post then [201, document(resource, add(resource, **attributes(resource, request.body).symbolize_keys))]
    when :get then [200, {"data" => all(resource).map { |record| item(resource, record) }, "meta" => meta}]
    end
  end

  def member(request, resource, record, action)
    case [request.method, action]
    in [:get, nil] then [200, document(resource, record)]
    in [:put, nil] then [200, document(resource, record.merge!(attributes(resource, request.body)))]
    in [:delete, nil] then destroy(resource, record["id"])
    in [:post, "ack"] then acknowledge(record["id"])
    in [:post, "activate"] then [200, document(resource, record.merge!("is_active" => true))]
    in [:post, "no_reply_needed"] then [200, document(resource, record.merge!("no_reply_needed" => true))]
    else nil
    end
  end

  def attributes(resource, body) = body.fetch(RESOURCES.fetch(resource), {})

  def push(resource)
    [200, {"data" => [{"id" => SecureRandom.uuid, "type" => "task"}],
           "meta" => {"message" => "Success", "warnings" => @warnings.delete(resource) || []}.compact_blank}]
  end

  def feed(resource)
    pending = all(resource).reject { |record| @acknowledged.include?(record["id"]) }
    [200, {"data" => pending.map { |record| item(resource, record) }, "meta" => meta}]
  end

  def destroy(resource, id)
    @store[resource].delete(id)
    [200, {"meta" => {"message" => "Success"}}]
  end

  def acknowledge(id)
    @acknowledged << id
    [200, {"meta" => {"message" => "Success"}}]
  end

  def document(resource, record) = {"data" => item(resource, record)}

  def item(resource, record)
    {"type" => RESOURCES.fetch(resource), "id" => record["id"], "attributes" => record}
      .merge(record.slice("relationships"))
  end

  def meta = {"page" => 1, "limit" => 100, "total" => nil}.compact

  def not_found = [404, {"errors" => {"code" => "resource_not_found", "title" => "Resource Not Found"}}]

  def unserved(request)
    raise Minitest::Assertion, "FakeChannex doesn't serve #{request.method.upcase} #{request.path}"
  end
end

module FakeChannexApi
  extend ActiveSupport::Concern

  included do
    teardown { Channex.configuration.api_key = @api_key_before_fake_channex if @fake_channex }
  end

  private

  # The Channex API for this test. It sets a key so the client can be built
  # without one.
  def fake_channex
    @fake_channex ||= begin
      @api_key_before_fake_channex = Channex.configuration.api_key
      Channex.configuration.api_key ||= "fake-channex-key"
      FakeChannex.new.install(self)
    end
  end
end
