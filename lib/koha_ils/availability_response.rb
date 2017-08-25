require 'koha_ils/errorable'
module KohaIls
  class AvailabilityResponse
    include SAXMachine
    include KohaIls::Errorable
    elements :'dlf:record', class: AvailabilityRecord, as: :records
  end
end
