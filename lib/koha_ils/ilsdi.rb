module KohaIls
  class ILSDI
    class ServiceError < StandardError; end
    class InvalidConfiguration < StandardError; end
    include Observable

    def self.uri
      koha = KohaIls.configuration.base_path
      raise InvalidConfiguration.new('You must set a url for your Koha installation') if koha.nil?
      URI.join(koha, '/cgi-bin/koha/ilsdi.pl')
    end

    # Calls ILSDI and returns response body
    # Throws ServiceError if something goes wrong
    def self.get(params)
      client = self.new
      KohaIls.configuration.observers.each {|obs| client.add_observer(obs) }
      client.query(params)
    end

    def query(params)
      uri = ILSDI.uri
      uri.query = URI.encode_www_form(params)
      start = Time.now
      resp = Net::HTTP.get_response(uri)
      raise "ERROR - #{resp.code} - #{resp.message}" unless ILSDI.successful?(resp)
      # allow monitoring of qtime using Observable
      time_taken = Time.now - start
      changed
      notify_observers(uri.to_s, time_taken)
      resp.body
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      raise ServiceError.new(e.message)
    end

    def self.get_patron_info(id)
      params = {
        service: 'GetPatronInfo',
        patron_id: id,
        show_contact: 1,
        show_loans: 1,
        show_fines: 1,
        show_holds: 1,
        show_attributes: 1
      }
      response = ILSDI.get(params)
      KohaIls::Patron.parse(response)
    rescue ILSDI::ServiceError => e
      p = KohaIls::Patron.new
      p.message = e.message
      p
    end

    def self.hold_item(patron_id:, bib_id:, item_id:, pickup_location:)
      params = {
        service: 'HoldItem',
        patron_id: patron_id,
        bib_id: bib_id,
        item_id: item_id,
        pickup_location: pickup_location
      }
      response = ILSDI.get(params)
      HoldItem.parse(response)
    rescue ServiceError => e
      h = HoldItem.new
      h.message = "HoldItem failed - #{e.message}"
      h
    end

    # Note the request location is required but not used by koha
    # so we fill it with a dummy value here
    def self.hold_title(patron_id:, bib_id:, pickup_location:, request_location: '127.0.0.1')
      params = {
        service: 'HoldTitle',
        patron_id: patron_id,
        bib_id: bib_id,
        request_location: request_location,
        pickup_location: pickup_location
      }
      response = ILSDI.get(params)
      HoldTitle.parse(response)
    rescue ServiceError => e
      h = HoldTitle.new
      h.message = e.message
      h
    end

    def self.cancel_hold(patron_id: patron_id, hold_id: hold_id)
      params = {
        service: 'CancelHold',
        patron_id: patron_id,
        item_id: hold_id
      }
      response = ILSDI.get(params)
      CancelHold.parse(response)
    rescue ServiceError => e
      h = CancelHold.new
      h.message = e.message
      h
    end

    def self.renew_loan(patron_id: patron_id, item_id: item_id)
      params = {
        service: 'RenewLoan',
        patron_id: patron_id,
        item_id: item_id
      }
      response = ILSDI.get(params)
      RenewLoan.parse(response)
    rescue ServiceError => e
      r = RenewLoan.new
      r.message = e.message
      r
    end

    def self.get_availability(ids)
      params = {
        service: 'GetAvailability',
        id: ids.join(' '),
        id_type: 'bib'
      }
      response = ILSDI.get(params)
      AvailabilityResponse.parse(response)
    rescue ServiceError => e
      a = AvailabilityResponse.new
      a.message = e.message
      a
    end

    def self.get_records(ids)
      params = {
        service: 'GetRecords',
        id: ids.join(' ')
      }
      response = ILSDI.get(params)
      RecordsResponse.parse(response)
    rescue ServiceError => e
      r = RecordsResponse.new
      r.message = e.message
      r
    end

    def self.successful?(response)
      (200..308).include? response.code.to_i
    end
  end
end
