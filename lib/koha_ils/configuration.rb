module KohaIls
  class Configuration
    attr_accessor :base_path
    attr_accessor :observers

    def initialize
      @base_path = nil
      @observers = []
    end
  end
end
