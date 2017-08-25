require 'spec_helper'

describe KohaIls do
  it 'has a version number' do
    expect(KohaIls::VERSION).not_to be nil
  end
  it 'can be configured' do
    KohaIls.configure do |config|
      expect(config).to be_a KohaIls::Configuration
    end
  end
end
