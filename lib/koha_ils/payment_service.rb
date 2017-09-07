module KohaIls
  class LoginError < StandardError
  end

  # Handles payment of fines in Koha.
  #
  # ## Usage
  #
  # Paying multiple fines
  #
  # KohaIls::PaymentService.connect do |ps|
  #   ps.make_payment(payment1)
  #   ps.make_payment(payment2)
  # end
  #
  #  Paying individual fines
  #
  #  KohaIls::PaymentService.make_payment(payment)
  #
  class PaymentService
    FineData = Struct.new(:id, :amount, :processed, :message)
    PaymentResponse = Struct.new(:successful, :message)

    def fine_payments_uri(id)
      URI.join(KohaIls.configuration.base_path, payments_api(id))
    end

    def payments_api(id)
      "/api/v1/accountlines/#{id}/partialpayment"
    end

    def login_uri
      URI.join(KohaIls.configuration.base_path, '/cgi-bin/koha/opac-user.pl')
    end

    def user
      KohaIls.configuration.payments_user
    end

    def password
      KohaIls.configuration.payments_password
    end

    # Open a connection to Koha and process
    # all payments
    # If login fails, return all objects
    # with error messages.
    #
    # :arg: payments - array of FineData structs
    def self.make_payments(payments)
      processed_payments = []
      PaymentService.connect do |ps|
        processed_payments = payments.map {|py| ps.process_fine(py) }
      end
      processed_payments
    rescue LoginError => e
      processed_payments = payments.map do |py|
        py.message = "Payment failed due to service login error"
        py.processed = false
        py
      end
      processed_payments
    end

    def self.connect
      ps = PaymentService.new
      if block_given?
        ps.login!
        ps.open_connection!
        yield ps
        ps.close_connection!
      end
      ps
    end

    # To login to Koha we need to use the OPAC login API
    # and store the cookie returned.
    # Note that Koha does not return a HTTP error if login fails
    # so we need to check the login text
    def login!
      uri = self.login_uri
      res = Net::HTTP.post_form(uri, userid: user, password: password)
      raise LoginError if login_error?(res)
      @cookie = res['Set-Cookie'].sub(/ path.*/, '')
    rescue SocketError => e
      raise LoginError
    end

    def login_error?(res)
      res.body =~ /incorrect username or password/i
    end

    def open_connection!
      uri = URI(KohaIls.configuration.base_path)
      @http = Net::HTTP.start(uri.host, uri.port)
    end

    def close_connection!
      @http.finish if @http.active?
    end

    def process_fine(fine)
      # Guard clause - prevent double payment
      return fine if fine.processed == true
      pay_resp = pay(fine.id, fine.amount)
      fine.processed = pay_resp.successful
      fine.message = pay_resp.message
      fine
    end

    def pay(id, amount)
      req = Net::HTTP::Put.new(fine_payments_uri(id))
      req.body = { amount: amount, note: "Automated Payment for fine: #{id}" }.to_json
      req['Content-Type'] = 'application/json'
      req['Cookie'] = @cookie
      response = @http.request(req)
      PaymentResponse.new(response.is_a?(Net::HTTPSuccess), response.body)
    end
  end
end
