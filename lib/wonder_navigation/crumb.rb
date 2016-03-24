module WonderNavigation
  class Crumb
    attr_accessor :label, :path, :id

    def initialize(id, label = nil)
      @id    = id
      @label = label
    end
  end
end
