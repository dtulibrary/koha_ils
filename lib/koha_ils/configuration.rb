module KohaIls
  class Configuration
    attr_accessor :base_path
    attr_accessor :observers
    attr_accessor :payments_user
    attr_accessor :payments_password
    attr_accessor :login_api

    def initialize
      @base_path = nil
      @observers = []
      @payments_user = ''
      @payments_password = ''
      @login_api = ''
    end
  end
end
