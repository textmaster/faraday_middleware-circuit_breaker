# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday_middleware/circuit_breaker/version'

Gem::Specification.new do |spec|
  spec.name          = "faraday_middleware-circuit_breaker"
  spec.version       = FaradayMiddleware::CircuitBreaker::VERSION
  spec.authors       = ["Pierre-Louis Gottfrois"]
  spec.email         = ["pierre-louis@textmaster.com"]

  spec.summary       = %q{Middleware to apply circuit breaker pattern.}
  spec.description   = %q{A Faraday Middleware to handle spotty web services.}
  spec.homepage      = "https://github.com/textmaster/faraday_middleware-circuit_breaker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'stoplight', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
