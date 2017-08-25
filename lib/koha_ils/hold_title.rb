module KohaIls
  class HoldTitle
    include SAXMachine
    include KohaIls::Errorable
    element :pickup_location
    element :title
    element :code

    attr_accessor :message

    def successful?
      code.nil? && @message.nil?
    end

    def message
      @message || code
    end
  end
end
