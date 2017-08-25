module KohaIls
  class Fine
    include SAXMachine
    element :note
    element :description
    element :amount, class: Float
    element :amountoutstanding, as: :amount_outstanding, class: Float
    element :accountlines_id, as: :id
    element :itemnumber, as: :item_number
    element :timestamp do |elem|
      Date.parse(elem)
    end

    def text
      [note, description].select {|t| t }.join(', ')
    end
  end
end

