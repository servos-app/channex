# Channex

A clean, idiomatic Ruby client for the [Channex.io](https://channex.io) channel
manager API — properties, room types, rate plans, availability, restrictions,
bookings, webhooks, and more.

## Installation

The gem isn't published to a registry. Add it to your `Gemfile` from GitHub:

```ruby
gem "channex", github: "servos-app/channex"
```

Then:

```bash
bundle install
```

Requires Ruby >= 3.2.

## Configuration

Configure globally once, typically in an initializer:

```ruby
Channex.configure do |config|
  config.api_key     = ENV["CHANNEX_API_KEY"]
  config.environment = :production   # :staging (default), :production,
                                     # :secure_staging, :secure_production
  config.timeout     = 30            # read timeout (seconds)
  config.open_timeout = 10           # connection timeout (seconds)
  config.logger      = Rails.logger  # optional; logs requests/responses at debug
end

client = Channex::Client.new
```

Or configure per-client, overriding the globals:

```ruby
client = Channex::Client.new(
  api_key: "your-api-key",
  environment: :staging
)
```

## Usage

### Resources

Each resource is reachable from the client and exposes CRUD plus pagination:

```ruby
client.properties.list
client.properties.retrieve("property-uuid")
client.properties.create(title: "My Hotel", currency: "USD", ...)
client.properties.update("property-uuid", title: "New Name")
client.properties.delete("property-uuid")
```

Available resources: `properties`, `room_types`, `rate_plans`, `availability`,
`restrictions`, `bookings`, `booking_revisions`, `channels`, `webhooks`,
`taxes`, `tax_sets`, `photos`, `groups`, `group_users`, `property_users`,
`facilities`, `messages`, `message_threads`, `attachments`, `hotel_policies`,
`availability_rules`.

### Pagination

```ruby
# One page
response = client.properties.list(page: 1, limit: 50)
response.data
response.pagination.has_next?

# Every page, collected
all = client.properties.list_all

# Every page, streamed (avoids loading everything into memory)
client.properties.list_all do |page|
  page.each { |property| process(property) }
end
```

### Filtering and ordering

```ruby
client.bookings.list(
  property_id: "property-uuid",
  status: "new",
  date_from: "2024-01-01",
  date_to: "2024-01-31",
  order: { inserted_at: :asc }
)
```

### Availability & Restrictions (ARI)

Read by property and date range; write in bulk:

```ruby
client.availability.list(
  property_id: "property-uuid",
  date_from: "2024-01-01",
  date_to: "2024-01-31"
)

client.availability.update([
  {
    property_id: "property-uuid",
    room_type_id: "room-uuid",
    date_from: "2024-01-15",
    date_to: "2024-01-20",
    availability: 5
  }
])

client.restrictions.update([
  {
    property_id: "property-uuid",
    rate_plan_id: "rate-plan-uuid",
    date_from: "2024-01-15",
    date_to: "2024-01-20",
    rate: 30000,
    min_stay_arrival: 2,
    closed_to_arrival: false,
    stop_sell: false
  }
])
```

### Receiving bookings

New bookings arrive through the booking revisions feed. **You must acknowledge
each revision after processing** — unacknowledged revisions are re-served for 30
minutes and then trigger email warnings.

```ruby
response = client.booking_revisions.feed

response.objects.each do |revision|   # typed Channex::Objects::BookingRevision
  puts revision.customer.full_name
  puts revision.check_in_date         # Date
  revision.rooms.each { |room| puts room.nights }

  client.booking_revisions.acknowledge(revision.id)
end
```

Raw hash access is available via `response.data` if you prefer.

### Guest messages

Channex unifies the guest inboxes of Booking.com, Airbnb and Expedia behind one
API. A **message thread** is one conversation; threads are the channel-agnostic
entry point because they also cover conversations with no booking behind them —
an Airbnb inquiry is a thread about a stay that does not exist yet.

```ruby
threads = client.message_threads.list(property_id: "property-uuid")
thread = Channex::Objects::MessageThread.from_resource(threads.data.first)

thread.title          # => "Maldonado Roxy"
thread.provider       # => "BookingCom"
thread.booking_id     # => nil for an Airbnb inquiry
thread.last_message   # => Channex::Objects::Message

messages = client.message_threads.messages(thread.id, order: {inserted_at: :asc})
messages.data.map { |node| Channex::Objects::Message.from_resource(node) }
        .each { |message| puts "#{message.sender}: #{message.message}" }

client.message_threads.send_message(thread.id, message: "Check-in is from 15:00.")
```

The same conversation is reachable from the booking it belongs to:

```ruby
client.messages.list(booking_id: "booking-uuid")
client.messages.send_message(booking_id: "booking-uuid", message: "See you soon!")
```

Sending a file is two calls — upload, then send the returned id:

```ruby
attachment = client.attachments.create(
  file: Base64.strict_encode64(File.binread("directions.jpeg")),
  file_name: "directions.jpeg",
  file_type: "image/jpeg"
)

client.message_threads.send_message(thread.id, attachment_id: attachment.data["id"])
```

Two thread actions round out the inbox: `close(id)` archives a thread, and
`no_reply_needed(id)` tells Booking.com a guest message needs no answer so its
response-time score stays honest.

Every call here needs the Messages application installed on the property,
otherwise Channex answers `403 Forbidden`. Bookings from an OTA without a
messaging API answer `422 Unprocessable Entity` (`not_supported`).

### Typed objects

Booking data is wrapped in typed objects that still behave like hashes:

```ruby
revision.status          # typed accessor
revision.new?            # => true
revision["booking_id"]   # hash access
revision.dig("customer", "mail")
revision.to_h            # underlying hash
```

## Error handling

All errors inherit from `Channex::Errors::Error` and carry `#code` and
`#response`:

```ruby
begin
  client.properties.retrieve("missing-uuid")
rescue Channex::Errors::NotFoundError => e
  e.code      # => 404
rescue Channex::Errors::ValidationError => e
  e.errors    # => [...] validation details
rescue Channex::Errors::RateLimitError => e
  e.retry_after
rescue Channex::Errors::Error => e
  e.response
end
```

| Status | Error class            |
| ------ | ---------------------- |
| 401    | `AuthenticationError`  |
| 403    | `ForbiddenError`       |
| 404    | `NotFoundError`        |
| 422    | `ValidationError`      |
| 429    | `RateLimitError`       |
| 5xx    | `ServerError`          |
| —      | `ConnectionError`, `TimeoutError`, `ConfigurationError` |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Run the
test suite with:

```bash
bundle exec rake test
```

Or `bin/console` for an interactive prompt.

Class loading uses [Zeitwerk](https://github.com/fxn/zeitwerk): files under
`lib/channex/` are autoloaded by convention (file path mirrors constant name),
so no manual `require` statements are needed when adding new resources or
objects.

## License

MIT.
