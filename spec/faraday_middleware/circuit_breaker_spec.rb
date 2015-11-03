describe FaradayMiddleware::CircuitBreaker do

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
      end
    end
  end

  it { expect(connection.get('/success').status).to eq(200) }
  it { expect(connection.get('/failure').status).to eq(500) }
  it { expect(connection.get('/blank').status).to eq(503) }

  describe 'on failure' do

    let(:fallback) { double }
    let(:response) { Faraday::Response.new(status: 503, response_headers: {}) }

    it 'calls fallback' do
      expect(fallback).to receive(:foo).and_return(response)
      expect(connection(fallback: fallback.method(:foo)).get('/blank').status).to eq(503)
    end

  end

end
