require 'spec_helper'

describe KohaIls::HoldTitle do
  let(:hold_resp) { File.read("spec/fixtures/holdTitle/#{resp_file}") }
  subject { described_class.parse(hold_resp) }
  context 'successful' do
    let(:resp_file)  { 'successful.xml' }
    it 'should be marked as successful' do
      expect(subject.successful?).to eql true
    end
  end
  context 'unsuccessful' do
    let(:resp_file)  { 'unsuccessful.xml' }
    it 'should not be marked as successful' do
      expect(subject.successful?).to eql false
    end
  end
end
