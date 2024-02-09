# FaradayMiddleware::CircuitBreaker

A Faraday Middleware to handle spotty web services.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday_middleware-circuit_breaker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faraday_middleware-circuit_breaker

## Usage

Simply add the middleware:

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker
end
```

## Configuration

### Timeout

Middleware will automatically attempt to recover after a certain amount of time. This timeout is customizable:

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, timeout: 10
end
```

The default is `60` seconds. To disable automatic recovery, set the timeout to `Float::INFINITY`. To make automatic recovery
instantaneous, set the timeout to `0` seconds though it's not recommended.

### Threshold

Some services might be allowed to fail more or less frequently than others. You can configure this by setting a custom threshold:

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, threshold: 5
end
```

The default is `3` times.

### Custom fallback

On a failure, middleware will render an empty `503` http response by default. You can customize the fallback response:

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, fallback: ->(env, exception) { # do something }
end
```

Middleware will try to call the `call` method on `fallback` passing 2 arguments:

- `env` -- the connection environement from faraday
- `exception` -- the exception raised that triggered the circuit breaker

You can pass a method to be eager called like this:

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, fallback: method(:foo)
end

def foo(env, exception)
  # do something
end
```

Whatever you chose, your method should return a valid faraday response. For example, here is the default fallback implementation:

```ruby
proc { Faraday::Response.new(status: 503, response_headers: {}) }
```

### Custom error handling

In some situations, it might required to allow for particular error types to be exempt from tripping the circuit breaker
(like regular 403 or 401 HTTP responses, which aren't really out-of-the-ordinary conditions that should trip the circuit breaker).
The underlying stoplight gem supports [custom error handling](https://github.com/orgsync/stoplight#custom-errors),
The `error_handler` option allows you to add your own customer error handler behavior:

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, error_handler: ->(exception, handler) { # do something }
end
```

Middleware will try to call the `call` method on `error_handler` passing 2 arguments:

- `exception` -- the exception raised that triggered the circuit breaker
- `handler` -- the current error handler `Proc` that would be in charge of handling the `exception` if no `error_handler` option was passed

You can pass a method to be eager called like this (with a handler that exempts `ArgumentError` from tripping the circuit):

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, error_handler: method(:foo)
end

def foo(exception, handler)
  raise exception if exception.is_a?(ArgumentError)
  handler.call(exception)
end
```

NOTE: It is most always a good idea to call the original `handler` with the exception that was passed in at the end of your
handler. (By default, the `error_handler` will just be [`Stoplight::Default::ERROR_HANDLER`](https://github.com/orgsync/stoplight/blob/master/lib/stoplight/default.rb#L9))

### Custom Stoplight key

By default, the circuit breaker will count failures by domain, but this logic can be tweak by passing a lambda to the `cache_key_generator` option.
The lambda will receive the [URI](https://docs.ruby-lang.org/en/2.1.0/URI.html) that Faraday is trying to call, and whatever string it returns will be used as the key to count the errors,
and all URI with the same key will trip together.

The default behaviour is:

```ruby
Faraday.new(url: 'http://foo.com/bar') do |c|
  c.use :circuit_breaker, cache_key_generator: ->(url) { URI.join(url, '/').to_s }
end
```

But for instance if when `http://foo.com/bar?id=1` trips you also want `http://foo.com/bar?id=2` to be tripped but `http://foo.com/foo` to go through, then you could pass the following:

```ruby
Faraday.new(url: 'http://foo.com/bar') do |c|
  c.use :circuit_breaker, cache_key_generator: lambda do |url|
        base_url = url.clone
        base_url.fragment = base_url.query = nil
        base_url.to_s
      end
end
```

Because the key is a simple string, it doesn't have to be constructed from the URI directly, so the following is also valid:

```ruby
Faraday.new(url: 'http://foo.com/bar') do |c|
  c.use :circuit_breaker, cache_key_generator: lambda do |url|
        if url.hostname == 'api.mydomain.com'
          if url.path.start_with? "/users"
            return "user_service"
          elsif url.path.start_with? "/orders"
            return "orders_service"
          else
            return "other_service"
          end
        end

        URI.join(url, '/').to_s
      end
end
```

### Notifiers

Middleware send notifications to standard error by default. You can customize the receivers.

#### Logger

To send notifications to a logger:

```ruby
Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, notifiers: { logger: Rails.logger }
end
```

#### Honeybadger

To send notifications to honeybadger:

```ruby
require 'honeybadger'

Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, notifiers: { honeybadger: "api_key" }
end
```

You'll need to have [Honeybadger](https://rubygems.org/gems/honeybadger) gem installed.

#### Slack

To send notifications to slack:

```ruby
require 'slack-notifier'

slack = Slack::Notifier.new('http://www.example.com/webhook-url')

Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, notifiers: { slack: slack }
end
```

You'll need to have [Slack](https://rubygems.org/gems/slack-notifier) gem installed.

#### HipChat

To send notifications to hipchat:

```ruby
require 'hipchat'

hip_chat = HipChat::Client.new('token')

Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, notifiers: { hipchat: { client: hipchat, room: 'room' } }
end
```

You'll need to have [HipChat](https://rubygems.org/gems/hipchat) gem installed.

#### Bugsnag

To send notifications to bugsnag:

```ruby
require 'bugsnag'

Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, notifiers: { bugsnag: Bugsnag }
end
```

You'll need to have [Bugsnag](https://rubygems.org/gems/bugsnag) gem installed.

#### Sentry

To send notifications to sentry:

```ruby
require 'sentry-raven'

sentry_raven = Raven::Configuration.new

Faraday.new(url: 'http://foo.com') do |c|
  c.use :circuit_breaker, notifiers: { sentry: sentry_raven } # or { raven: sentry_raven }
end
```

You'll need to have [Sentry](https://rubygems.org/gems/sentry-raven) gem installed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/faraday_middleware-circuit_breaker.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
