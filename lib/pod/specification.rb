module Pod

  class Specification

    # Ignore invalid assignments in podspecs.
    #
    def method_missing name, *args, &block
      super unless name[-1..-1] == '='
    end

  end
end