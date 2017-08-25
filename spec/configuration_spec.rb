require 'spec_helper'

module KohaIls
  describe Configuration do
    describe 'base_path' do
      it 'default value is nil' do
        expect(described_class.new.base_path).to be_nil
      end
    end
    describe 'base_path=' do
      it 'can set the value' do
        config = described_class.new
        config.base_path = 'http://koha.library.dk'
        expect(config.base_path).to eq 'http://koha.library.dk'
      end
    end
    describe 'observers' do
      it 'default value is []' do
        config = described_class.new
        expect(config.observers).to eql []
      end
    end
    class DummyObserver; end
    describe 'observers=' do
      it 'can set the value' do
        config = described_class.new
        config.observers = [DummyObserver]
        expect(config.observers).to include DummyObserver
      end
    end
  end
end
