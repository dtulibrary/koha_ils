module KohaIls
  class Patron
    include SAXMachine
    include KohaIls::Errorable

    element :firstname, as: :first_name, class: String
    element :surname, class: String
    element :charges, class: Float, default: 0.0

    elements :fine, as: :fines, class: KohaIls::Fine
    elements :hold, as: :reservations, class: KohaIls::Reservation
    elements :loan, as: :loans, class: KohaIls::Loan

    def name
      @name ||= "#{first_name} #{surname}"
    end

    def active_fines
      fines.select {|fine| fine.amount_outstanding.to_f > 0 }
    end

    def has_fine?(id: id, amount: amount)
      active_fines.any? {|f| (f.id.to_i == id.to_i) && (f.amount_outstanding.to_f >= amount.to_f) }
    end

    # Test if the given fine data corresponds with a user's actual fines
    def has_fines?(fine_data)
      fine_data.map { |id, amt| has_fine?(id: id, amount: amt) }.all?
    end

    def total_outstanding
      active_fines.reduce(0) {|sum,fine| sum += fine.amount.to_f }
    end

    def active_events
      (loans + reservations + active_fines).sort_by(&:timestamp)
    end
  end
end
