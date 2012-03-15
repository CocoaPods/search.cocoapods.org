module Pod

  class Specification
    
    # Returns a list of all subspecs.
    #
    # TODO Eventually use the method supplied by CocoaPods
    #
    def recursive_subspecs
      mapper = lambda do |spec|
        spec.subspecs.map do |subspec|
          [subspec, *mapper.call(subspec)]
        end.flatten
      end

      mapper.call self
    rescue StandardError
      []
    end

    # Ignore invalid assignments in podspecs.
    #
    def method_missing name, *args, &block
      super unless name[-1..-1] == '='
    end

  end
end