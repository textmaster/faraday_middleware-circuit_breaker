require 'spec_helper'

describe FaradayMiddleware::CircuitBreaker do
  it 'has a version number' do
    expect(FaradayMiddleware::CircuitBreaker::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
