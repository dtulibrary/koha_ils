require 'spec_helper'
require 'webmock/rspec'

describe KohaIls::Patron do
  let(:service_resp) { File.read("spec/fixtures/#{resp_path}/#{resp_file}") }
  let(:resp_path) { 'getPatronInfo' }
  let(:resp_file) { 'patron_info.xml' }
  let(:patron) { KohaIls::Patron.parse(service_resp) }
  describe 'attributes' do
    it 'should have the name' do
      expect(patron.name).to eql 'Bob Arctor'
    end
    it 'should have the total charges' do
      expect(patron.charges).to eql 0.00
    end
  end
  describe 'fines' do
    subject(:fines) { patron.fines }
    it { should be_an Array }
  end
  describe 'a fine' do
    let(:fine) { patron.fines.first }
    it 'should have the original amount' do
      expect(fine.amount).to eql 25.00
    end
    it 'should have a description' do
      expect(fine.description).to eql 'Coffee stains'
    end
    it 'should have a note' do
      expect(fine.note).to eql 'Some note text'
    end
  end
  context 'with active fines' do
    let(:resp_file) { 'patron_info_fines.xml' }
    describe 'active fines' do
      it 'should only show the fines that have not been paid' do
        expect(patron.active_fines.size).to eql 2
      end
    end
    describe 'has_fine?' do
      it 'returns true when a user has a fine with the given id and amount' do
        expect(patron.has_fine?(id: 5, amount: 10.0)).to eq true
      end
      it 'returns false when a user does not have a fine corresponding to a given id' do
        expect(patron.has_fine?(id: 15, amount: 10.0)).to eq false
      end
      it 'returns false when a payment amount is greater than that outstanding on the fine' do
        expect(patron.has_fine?(id: 5, amount: 20.0)).to eq false
      end
    end
    describe 'has_fines?' do
      it 'returns false if a patron does not have one or more of the fines in question' do
        expect(patron.has_fines?([[5, 10], [11, 17]])).to eq false
      end
      it 'returns true if a patron has all of the fines in question' do
        expect(patron.has_fines?([[5, 10], [6, 17]])).to eq true
      end
    end
  end

  describe 'reservations' do
    subject(:reservations) { patron.reservations }
    it { should be_an Array }
  end
  describe 'a request' do
    let(:request) { patron.reservations.first }
    it 'should have a title' do
      expect(request.title).to eql 'Another test'
    end
    it 'should have a reserved date' do
      expect(request.date_reserved).to eql Date.parse('2017-01-30')
    end
  end
  describe 'loans' do
    subject(:loans) { patron.loans }
    it { should be_an Array }
  end
  describe 'a loan' do
    let(:loan) { patron.loans.first }
    it 'should have a due date' do
      expect(loan.date_due).to eql Date.parse('2017-04-07')
    end
    it 'should have a title' do
      expect(loan.title).to eql 'Another test'
    end
  end
  describe 'reservations' do
    subject { patron.reservations }
    it { should be_an Array }
  end
  describe 'a reservation waiting' do
    let(:resp_file) { 'hold_waiting.xml' }
    subject { patron.reservations.first }
    it { should be_a KohaIls::Reservation }
    it 'should be marked as waiting' do
      expect(subject.waiting?).to eql true
    end
  end
end
