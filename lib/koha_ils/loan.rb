module KohaIls
  class Loan
    include SAXMachine
    element :title
    element :itemnumber, as: :item_id
    element :replacementprice
    element :timestamp do |elem|
      Date.parse(elem)
    end
    element :date_due do |elem|
      Date.parse(elem)
    end
    element :date_issued do |elem|
      Date.parse(elem)
    end
  end
end
