module KohaIls
  class RecordsResponse
    include SAXMachine
    include KohaIls::Errorable
    elements :record, class: Record, as: :records
  end
end

