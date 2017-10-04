module KohaIls
  class Reservation
    include SAXMachine
    element :title
    element :reservedate, as: :date_reserved do |elem|
      Date.parse(elem)
    end
    element :branchname, as: :branch
    element :reserve_id
    element :priority
    element :found
    element :borrowernumber, as: :borrower_number
    element :timestamp do |elem|
      Date.parse(elem)
    end

    def waiting?
      found == 'W'
    end

    def transit?
      found == 'T'
    end
  end
end
