module KohaIls
  class AvailabilityItem
    include SAXMachine
    element :'dlf:identifier', as: :id
    element :'dlf:availabilitystatus', as: :availability
    element :'dlf:location', as: :location
  end
  class AvailabilityRecord
    include SAXMachine
    elements :'dlf:item', class: AvailabilityItem, as: :items
    element 'dlf:bibliographic', value: :id, as: :id
  end
end
