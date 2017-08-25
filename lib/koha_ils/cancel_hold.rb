module KohaIls
  class CancelHold
    include SAXMachine
    include KohaIls::Errorable
    element :code

    def successful?
      code == 'Canceled'
    end
  end
end
