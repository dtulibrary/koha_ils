module KohaIls
  module Errorable

    attr_accessor :message

    def successful?
      response_code.nil? && @message.nil?
    end

    def response_code
      defined?(code) ? code : nil
    end

    def message
      @message || response_code
    end
  end
end
