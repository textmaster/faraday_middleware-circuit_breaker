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

  describe 'using response_handler for adding custom failure criteria' do
    let(:light) { double }
    let(:http_code) { 500 }
    let(:http_client) do
      connection(
        response_handler: ->(response){
          code = response.status
          raise StandardError.new("Got response #{code}") if code == http_code
          response
        },
        fallback: ->(_, exception){
          Faraday::Response.new(status: http_code, response_headers: {})
        }
      )
    end

    before { allow(light).to receive(:name).and_return('http:/') }

    def failures
      Stoplight::Light.default_data_store.get_failures(light)
    end

    it 'will increase spotlight failure based on response_handler logic' do
      expect(http_client.get('/success').status).to eq(200)
      expect(failures.length).to eq(0)

      expect(http_client.get('/failure').status).to eq(http_code)
      expect(failures.length).to eq(1)
    end
  end
end
