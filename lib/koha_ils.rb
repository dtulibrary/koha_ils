require 'observer'
require 'sax-machine'
require "koha_ils/version"
require "koha_ils/configuration"
require 'koha_ils/errorable.rb'
require 'koha_ils/availability_record.rb'
require 'koha_ils/availability_response.rb'
require 'koha_ils/cancel_hold.rb'
require 'koha_ils/fine.rb'
require 'koha_ils/hold_item.rb'
require 'koha_ils/hold_title.rb'
require 'koha_ils/loan.rb'
require 'koha_ils/reservation.rb'
require 'koha_ils/patron.rb'
require 'koha_ils/payment_service.rb'
require 'koha_ils/record.rb'
require 'koha_ils/record_service.rb'
require 'koha_ils/records_response.rb'
require 'koha_ils/renew_loan.rb'
require 'koha_ils/ilsdi.rb'

module KohaIls
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
