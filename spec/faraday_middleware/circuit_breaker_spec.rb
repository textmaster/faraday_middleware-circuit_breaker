describe FaradayMiddleware::CircuitBreaker do

  before do
    Stoplight::Light.default_data_store = Stoplight::DataStore::Memory.new
  end

  def connection(options = {})
    Faraday.new do |c|
      c.use :circuit_breaker, options
      c.adapter :test do |stub|
        stub.get('/success') do
          [200, {}, '']
        end
        stub.get('/failure') do
          [500, {}, '']
        end
        stub.get('/query?key=error') do
          raise StandardError
        end
        stub.get('/query?key=success') do
          [200, {}, '']
        end
        stub.get('/argument_error') do
          raise ArgumentError
        end
        stub.get('/other_error') do
          raise EncodingError
        end
      end
    end
  end

  it { expect(connection.get('/success').status).to eq(200) }
  it { expect(connection.get('/failure').status).to eq(500) }
  it { expect(connection.get('/blank').status).to eq(503) }
  it { expect { connection.get('/argument_error') }.not_to raise_error}
  it { expect(connection.get('/argument_error').status).to eq(503)}
  it { expect { connection.get('/other_error') }.not_to raise_error}
  it { expect(connection.get('/other_error').status).to eq(503)}

  describe 'on failure' do

    let(:fallback) { double }
    let(:argument_error_handler) do
      ->(exception, handler) do
        raise exception if exception.is_a?(ArgumentError)
        handler.call(exception)
      end
    end

    let(:response) { Faraday::Response.new(status: 503, response_headers: {}) }

    it 'calls fallback' do
      expect(fallback).to receive(:foo).and_return(response)
      expect(connection(fallback: fallback.method(:foo)).get('/blank').status).to eq(503)
    end

    it 'calls error handler' do
      conn_with_err_handler = connection(error_handler: argument_error_handler)
      expect { conn_with_err_handler.get('/argument_error') }.to raise_error(ArgumentError)
      expect { conn_with_err_handler.get('/other_error') }.not_to raise_error
      expect { conn_with_err_handler.get('/failure') }.not_to raise_error
      expect { conn_with_err_handler.get('/success') }.not_to raise_error
    end
  end

  describe 'on failure with different query string' do

    let(:threshold) { 3 }

    before do
      Stoplight::Light.default_notifiers = []
    end

    it 'should still tripped' do
      conn = connection(threshold: threshold)
      threshold.times { conn.get('/query?key=error') }
      expect(conn.get('/query?key=success').status).to eq(503)
    end

  end

  describe 'with a different cache key generator' do
    let(:threshold) { 3 }
    let(:cache_key_generator) do
      lambda do |url|
        base_url = url.clone
        base_url.fragment = base_url.query = nil
        base_url.to_s
      end
    end

    it 'should not trip when the new key differs' do
      conn = connection(threshold: threshold, cache_key_generator: cache_key_generator)
      threshold.times { conn.get('/query?key=error') }
      expect(conn.get('/query?key=success').status).to eq(503)
      expect(conn.get('/success').status).to eq(200)
    end
  end

end
