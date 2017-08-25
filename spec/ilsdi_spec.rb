require 'spec_helper'

describe KohaIls::ILSDI do
  describe 'uri' do
    it 'raises an error if no base_path is set' do
      expect{ KohaIls::ILSDI.uri }.to raise_error KohaIls::ILSDI::InvalidConfiguration
    end
    it 'uses the url from the config' do
      KohaIls.configuration.base_path = 'http://koha.library.dk'
      expect(KohaIls::ILSDI.uri.to_s).to include 'koha.library.dk'
    end
  end
  describe 'methods: ' do
    let(:service_resp) { File.read("spec/fixtures/#{resp_path}/#{resp_file}") }
    before do
      allow(described_class).to receive(:get).and_return service_resp
    end
    describe 'get_patron' do
      subject(:patron) { KohaIls::ILSDI.get_patron_info(29) }
      let(:resp_path) { 'getPatronInfo' }
      let(:resp_file) { 'patron_info.xml' }
      context 'when the service is responding' do
        it 'should return an ok patron object' do
          expect(patron).to be_a KohaIls::Patron
          expect(patron.successful?).to eql true
        end
      end
      context 'when the service is unavailable' do
        before do
          allow(described_class).to receive(:get).and_raise KohaIls::ILSDI::ServiceError
        end
        it 'should return an errored patron object' do
          expect(patron).to be_a KohaIls::Patron
          expect(patron.successful?).to eql false
        end
      end
    end
    describe 'get_records' do
      subject { described_class.get_records([1,2,3]) }
      let(:resp_path) { 'getRecords' }
      context 'multiple items' do
        let(:resp_file)  { 'multiple.xml' }
        it 'should contain multiple record items' do
          expect(subject.records.size).to eq 3
        end
      end
      context 'single items' do
        let(:resp_file)  { 'single.xml' }
        it 'should contain only one record' do
          expect(subject.records.size).to eq 1
        end
      end
    end
    describe 'get_availability' do
      subject(:availability) { described_class.get_availability([1]) }
      let(:resp_path) { 'getAvailability' }
      let(:resp_file) { 'available.xml' }
      it 'should have records' do
        expect(subject.records.size).to eql 2
      end
    end
    describe 'renew_loan' do
      subject(:renewal) { described_class.renew_loan(patron_id: 1, item_id: 2) }
      let(:resp_path) { 'renewLoan' }
      context 'item already reserved' do
        let(:resp_file) { 'reserved.xml' }
        it 'should not be sucessful' do
          expect(renewal.successful?).to eq false
        end
        it 'should contain an error' do
          expect(renewal.error).to eq 'on_reserve'
        end
      end
      context 'renewal successful' do
        let(:resp_file) { 'success.xml' }
        it 'should be successful' do
          expect(renewal.successful?).to eq true
        end
        it 'should have a due date' do
          expect(renewal.date_due).to eq Date.parse('2017-07-17')
        end
      end
    end
    describe 'hold_title' do
      subject(:hold_title) { described_class.hold_title(patron_id: '946', bib_id: '4846', pickup_location: 'DTV') }
      let(:resp_path) { 'holdTitle' }
      context 'hold placed successfully' do
        let(:resp_file)  { 'successful.xml' }
        it { should be_a KohaIls::HoldTitle }
        it 'should be successful' do
          expect(subject.successful?).to be true
        end
      end
      context 'item cannot be held' do
        let(:resp_file)  { 'unsuccessful.xml' }
        it { should be_a KohaIls::HoldTitle }
      end
      context 'invalid pickup_location' do
        let(:pickup) { 'fakefakefake' }
        let(:resp_file)  { 'unsuccessful.xml' }
        it { should be_a KohaIls::HoldTitle }
        it 'should be unsuccessful' do
          expect(subject.message).to include 'NotHoldable'
          expect(subject.successful?).to eql false
        end
      end
    end
    describe 'hold_item' do
      let(:resp_path) { 'holdItem' }
      let(:resp_file) { 'successful.xml' }
      let(:pickup) { 'DTV' }
      subject { described_class.hold_item(patron_id: '946', bib_id: '4846', item_id: '2293', pickup_location: pickup)}
      context 'hold placed successfully' do
        it { should be_a KohaIls::HoldItem }
        it 'should be successful' do
          expect(subject.successful?).to be true
        end
      end
      context 'invalid pickup location' do
        let(:pickup) { 'blablabla' }
        let(:resp_file) { 'location_error.xml' }
        it { should be_a KohaIls::HoldItem }
        it 'should not be successful' do
          expect(subject.successful?).to be false
        end
      end
      context 'patron not found' do
        let(:resp_file) { 'patron_error.xml' }
        it { should be_a KohaIls::HoldItem }
        it 'should not be successful' do
          expect(subject.successful?).to be false
        end
      end
      context 'record not found' do
        let(:resp_file) { 'record_error.xml' }
        it { should be_a KohaIls::HoldItem }
        it 'should not be successful' do
          expect(subject.successful?).to be false
        end
      end
    end
  end
end
