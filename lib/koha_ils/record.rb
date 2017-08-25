module KohaIls
  class Record
    include SAXMachine
    include KohaIls::Errorable

    class Item
      include SAXMachine
      element :issues
      element :holdingbranchname, as: :branch_name
      element :itemcallnumber, as: :callnumber
      element :itype, as: :type
      element :itemnumber, as: :id
      element :itype, as: :type
      element :enumchron
      element :homebranch, as: :branch_code
      element :notforloan, as: :not_for_loan do |elem|
        elem.to_i > 0
      end
      element :date_due do |elem|
        Date.parse(elem)
      end
      element :itemlost, as: :item_lost do |elem|
        elem.to_i > 0
      end
      element :location
      element :permanent_location
      element :biblionumber, as: :biblio_number

      element :withdrawn do |elem|
        elem.to_i > 0
      end

      def for_loan?
        !not_for_loan
      end
    end

    element :biblionumber, as: :id
    elements :item, class: Item, as: :items
    elements :reserve, class: Reservation, as: :reservations
    element :marcxml
    attr_reader :host_bib_id, :host_item_id

    def item_ids
      items.map(&:id)
    end

    def has_reservations?
      reservations.any?
    end

    # Records which are contained within a parent item
    # and can thus only be loaned as part of that item
    def analytical?
      return false unless item_ids.empty?
      host_bib_id && host_item_id
    end

    def marc
      @marc  ||= Nokogiri::XML(marcxml).remove_namespaces!
    end

    def host_item
      @host_item ||= marc.xpath('./record/datafield[@tag="773"]')
    end

    def host_bib_id
      subfield = host_item.xpath('./subfield[@code="0"]').first
      subfield.text if subfield
    end

    def host_item_id
      subfield = host_item.xpath('./subfield[@code="9"]').first
      subfield.text if subfield
    end
  end
end
