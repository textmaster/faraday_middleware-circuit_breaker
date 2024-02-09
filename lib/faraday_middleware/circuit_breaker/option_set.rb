require 'faraday'
require 'stoplight'
require 'faraday_middleware/circuit_breaker/option_set'

module FaradayMiddleware
  module CircuitBreaker
    class OptionSet

      VALID_OPTIONS = %w(timeout threshold fallback notifiers data_store error_handler cache_key_generator)

      attr_accessor :timeout, :threshold, :fallback, :notifiers, :data_store, :error_handler, :cache_key_generator

      def initialize(options = {})
        @timeout    = options[:timeout] || 60.0
        @threshold  = options[:threshold] || 3
        @fallback   = options[:fallback] || proc { Faraday::Response.new(status: 503, response_headers: {}) }
        @notifiers  = options[:notifiers] || {}
        @data_store = options[:data_store] || proc { Stoplight::Light.default_data_store }
        @error_handler = options[:error_handler] || Stoplight::Default::ERROR_HANDLER
        @cache_key_generator = options[:cache_key_generator] || ->(url) { URI.join(url, '/').to_s }
      end

      def self.validate!(options)
        options.each_key do |key|
          unless VALID_OPTIONS.include?(key.to_s)
            fail ArgumentError.new("Unknown option: #{key}. Valid options are :#{VALID_OPTIONS.join(', ')}")
          end
        end
      end

    end
  end
end
