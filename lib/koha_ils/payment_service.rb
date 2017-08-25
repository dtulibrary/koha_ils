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
    def base_uri
      URI(Rails.application.config.koha[:base])
    end

    def fine_payments_uri(id)
      URI.join(Rails.application.config.koha[:base], payments_api(id))
    end

    def payments_api(id)
      "/api/v1/accountlines/#{id}/partialpayment"
    end

    def login_uri
      URI.join(Rails.application.config.koha[:base], '/cgi-bin/koha/opac-user.pl')
    end

    def user
      Rails.application.config.koha[:payments_user]
    end

    def password
      Rails.application.config.koha[:payments_password]
    end

    # Open a connection to Koha and process
    # all payments contained within a payment
    # object.
    def self.make_payment(payment)
      PaymentService.connect do |ps|
        payment = ps.make_payment(payment)
      end
    rescue LoginError => e
      payment.messages << "Payment failed due to service login error"
      payment.processed = false
      payment.save!
    ensure
      return payment
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
      res.body.include? "incorrect username or password"
    end

    def open_connection!
      uri = self.base_uri
      @http = Net::HTTP.start(uri.host, uri.port)
    end

    def close_connection!
      @http.finish if @http.active?
    end

    def make_payment(payment)
      fines = payment.fine_info.map { |fine| process_fine(fine) }
      payment.fine_info = fines
      payment.save!
      payment
    end

    def process_fine(fine)
      # Guard clause - prevent double payment
      return fine if fine.processed == true
      pay_resp = pay(fine.id, fine.amount)
      fine.processed = pay_resp.successful
      fine.message = pay_resp.message
      fine
    end

    PaymentResponse = Struct.new(:successful, :message)

    def pay(id, amount)
      req = Net::HTTP::Put.new(fine_payments_uri(id))
      req.body = { amount: amount, note: "Automated Payment from FindIt for fine: #{id}" }.to_json
      req['Content-Type'] = 'application/json'
      req['Cookie'] = @cookie
      response = @http.request(req)
      PaymentResponse.new(response.is_a?(Net::HTTPSuccess), response.body)
    end
  end
end
