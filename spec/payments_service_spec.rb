require 'spec_helper'

module KohaIls
  describe PaymentService do
    let(:base_path) { 'http://fake.blabla' }
    let(:login_api) { 'http://fake.blabla/cgi-bin/koha/opac-user.pl' }
    before do
      KohaIls.configure do |cfg|
        cfg.base_path = base_path
        cfg.login_api = login_api
        cfg.payments_user = ''
      end
    end
    describe 'making a payment' do
      let!(:fine_payment) { PaymentService::FineData.new(22, 5) }
      context 'when the service is unavailable' do
        before do
          WebMock.allow_net_connect!
        end
        it 'should fail to process the payment' do
          payment = PaymentService::FineData.new(22, 5)
          fine_payment = PaymentService.make_payments([payment]).first
          expect(fine_payment.processed).to eql false
        end
        after do
          WebMock.disable_net_connect!
        end
      end
      context 'when the service is available' do
        before do
          WebMock.stub_request(:post, "http://fake.blabla/cgi-bin/koha/opac-user.pl").
            to_return(:status => 200, :body => login_response, :headers => {'Set-Cookie' => 'CGISESSID=feb562bb03'})
        end
        context 'and login fails' do
          let(:login_response) { 'Incorrect username or password' }
          it 'should fail to process the payment' do
            payment = PaymentService.make_payments([fine_payment]).first
            expect(payment.processed).to eql false
          end
        end
        context 'and login succeeds' do
          let(:login_response) { 'Welcome' }
          before do
            WebMock.stub_request(:put, /http:\/\/fake.blabla\/api\/v1\/accountlines\/\d+\/partialpayment/).
              to_return(:status => response_code, :body => response_msg, :headers => {})
          end
          context 'but payment fails' do
            let(:response_code) { 403 }
            let(:response_msg) { "{\"error\": \"You don't have the required permission\"}" }
            it 'should fail to process the payment' do
              payment = PaymentService.make_payments([fine_payment]).first
              expect(fine_payment.processed).to eql false
            end
          end
          context 'payment succeeds' do
            let(:response_code) { 200 }
            let(:response_msg) { '{"accounttype":"F","notify_level":"0","description":"F 269017","date":"2017-04-28","borrowernumber":"946","dispute":null,"timestamp":"2017-05-05 11:46:24","notify_id":"1","itemnumber":"269017","lastincrement":null,"accountno":"8","issue_id":null,"accountlines_id":"14","manager_id":"1","amount":"10.000000","note":"Test 1","amountoutstanding":"5.000000"}' }
            it 'should process the payment successfully' do
              payment = nil
              payment = PaymentService.make_payments([fine_payment]).first
              expect(payment.processed).to eql true
            end
          end

        end
      end
    end
  end
end
