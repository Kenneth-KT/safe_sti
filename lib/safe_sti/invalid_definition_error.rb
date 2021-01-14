module SafeSti
  class InvalidDefinitionError < StandardError
    def initialize(value:)
      super("`safe_sti_child { x }` expecting x to be instance of Class, #{value.class.name} given")
    end
  end
end
