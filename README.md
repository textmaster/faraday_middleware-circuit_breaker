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

On a failure, middlware will render an empty `503` http response by default. You can customize the fallback response:

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/faraday_middleware-circuit_breaker.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

