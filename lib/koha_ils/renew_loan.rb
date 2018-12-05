module KohaIls
  class RenewLoan
    include SAXMachine
    include KohaIls::Errorable
    element :success, class: Integer
    element :error
    element :renewals
    element :code
    element :date_due do |elem|
      Date.parse(elem)
    end
    element :renewals, class: Integer

    def successful?
      success == 1
    end

    def message
      if successful?
        "Renewal succeeded, due date #{date_due}"
      else
        "Renewal failed: #{error_message}"
      end
    end

    # TODO - investigate other potential values
    def error_message
      if error == 'on_reserve'
        'another user has already reserved this item'
      elsif error == 'too_many'
        "you cannot renew a loan more than 10 times"
      elsif code == 'PatronNotFound'
        'problem with user id - please contact an administrator for assistance'
      end
    end
  end
end
