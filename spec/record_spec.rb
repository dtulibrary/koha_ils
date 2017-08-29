require 'spec_helper'

describe KohaIls::Record do
  let(:holdings_resp) { File.open("spec/fixtures/getRecords/#{resp_file}").read }
  let(:resp_file)  { 'single.xml' }
  subject(:record) { KohaIls::Record.parse(holdings_resp) }
  describe 'items' do
    it 'should contain one item' do
      expect(subject.items.size).to eq 1
    end
  end
  describe KohaIls::Record::Item do
    subject(:item) { record.items.first }
    it 'should have a callnumber' do
      expect(item.callnumber).to eql '62 Nanotechnology'
    end
    it 'should have a branch name' do
      expect(item.branch_name).to eql 'DTU Bibliotek Lyngby'
    end
    it 'should have number of issues' do
      expect(item.issues).to eql '9'
    end
    it 'should have a type' do
      expect(item.type).to eql 'LONGLOAN'
    end
  end
end
