require_relative 'lib/faraday_middleware/circuit_breaker/version'

Gem::Specification.new do |spec|
  spec.name          = "faraday_middleware-circuit_breaker"
  spec.version       = FaradayMiddleware::CircuitBreaker::VERSION
  spec.authors       = ["Pierre-Louis Gottfrois"]
  spec.email         = ["pierre-louis@textmaster.com"]

  spec.summary       = %q{Middleware to apply circuit breaker pattern.}
  spec.description   = %q{A Faraday Middleware to handle spotty web services.}
  spec.homepage      = "https://github.com/textmaster/faraday_middleware-circuit_breaker"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/textmaster/faraday_middleware-circuit_breaker"
  spec.metadata["changelog_uri"] = "https://github.com/textmaster/faraday_middleware-circuit_breaker/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '>= 0.9', '< 3.0'
  spec.add_dependency 'stoplight', '>= 2.1', '< 4.0'

  spec.add_development_dependency 'rspec'
end
