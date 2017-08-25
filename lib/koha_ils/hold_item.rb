module KohaIls
  class HoldItem
    include KohaIls::Errorable
    include SAXMachine
    element :pickup_location
    element :code
  end
end
