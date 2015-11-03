require 'faraday_middleware/circuit_breaker/version'
require 'faraday_middleware/circuit_breaker/middleware'

module FaradayMiddleware
  module CircuitBreaker

    if Faraday.respond_to?(:register_middleware)
      Faraday.register_middleware circuit_breaker: FaradayMiddleware::CircuitBreaker::Middleware
    elsif Faraday::Middleware.respond_to?(:register_middleware)
      Faraday::Middleware.register_middleware circuit_breaker: FaradayMiddleware::CircuitBreaker::Middleware
    end

  end
end
