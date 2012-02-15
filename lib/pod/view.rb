module Pod

  # "View" class to render results with.
  #
  class View < Struct.new(:id, :version, :summary, :authors, :link)
    
    # The view content cache.
    #
    # Structure:
    #   { id => [version, summary, authors, link] }
    #
    def self.content
      @content ||= {}
    end
    
    # Stores a new View model in the cache.
    #
    # Note: We could already prerender it if
    # necessary.
    #
    def self.add id, version, summary, authors, link
      content[id] = new id, version, summary, authors, link
    end

    # Stub find method coverts result ids into
    # an array of View models.
    #
    # Note: Picky calls this method from its
    # Results#populate_with method.
    #
    def self.find ids, options = {}
      ids.map { |id| content[id] }
    end
    
    # Renders a result for display
    # in the Picky front end.
    #
    def render
      rendered_authors = authors && authors.map do |name, _|
        %{<a href="javascript:pickyClient.insert('#{name}')">#{name}</a>}
      end
      rendered_authors = oxfordify rendered_authors
      %Q{<li class="result"><h3><a href="#{link}">#{id}</a> #{version}</h3><p>#{summary}</p><p class="author">#{rendered_authors}</p></li>}
    end
    
    # Examples:
    #  * Apples
    #  * Apples and Bananas
    #  * Apples, Oranges, and Bananas.
    #
    def oxfordify words
      if words.size < 3
        words.join ' and '
      else
        "#{words[0..-2].join(', ')}, and #{words.last}"
      end
    end

  end
end
