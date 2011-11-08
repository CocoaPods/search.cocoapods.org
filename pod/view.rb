module Pod

  # "View" class to render results with.
  #
  class View

    # Stub.
    #
    def self.find ids, options = {}
      ids.map { |id| new id }
    end

    attr_reader :id

    def initialize id
      @id = id
    end

    def to_s
      %Q{<div class="pod"><p>#{id}</p></div>}
    end

  end
end