module KohaIls
  class RecordService
    include SAXMachine
    elements :record, class: Record, as: :records

    def self.get(ids)
      params = {
        service: 'GetRecords',
        id: ids.join(' ')
      }
      response = ILSDI.get(params)
      self.parse(response).records
    rescue ILSDI::ServiceError => e
      [KohaIls::Record.errored(e.message)]
    end
  end
end
