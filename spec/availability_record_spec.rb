require 'spec_helper'

describe KohaIls::AvailabilityRecord do
  let(:file) { 'available.xml' }
  let(:response) { File.read("spec/fixtures/getAvailability/#{file}") }
  subject(:record) { KohaIls::AvailabilityRecord.parse(response) }
  it 'should have items' do
    expect(subject.items.size).to eql 2
  end
  it 'should have the bib id' do
    expect(subject.id).to eql '4731'
  end
  describe KohaIls::AvailabilityItem do
    subject { record.items.first }
    it 'should have an id' do
      expect(subject.id).to eql '3084'
    end
    it 'should have a location' do
      expect(subject.location).to eql 'DTU Bibliotek Lyngby'
    end
    it 'should have availability' do
      expect(subject.availability).to eql 'available'
    end
  end
end
