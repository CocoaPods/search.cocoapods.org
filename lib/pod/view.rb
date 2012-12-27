module Pod

  # "View" class to render results with.
  #
  class View < Struct.new(:id, :platforms, :version, :summary, :authors, :link, :subspecs)
    
    # The view content cache.
    #
    # Structure:
    #   { id => [platforms, version, summary, authors, link, [subspec1, subspec2, ...]] }
    #
    def self.content
      @content ||= {}
    end
    
    # Stores a new View model in the cache.
    #
    # Note: We could already prerender it if
    # necessary.
    #
    def self.add id, *args
      content[id] = new id, *args
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
    @@platform_mapping = {
      :ios  => 'iOS',
      :osx  => 'OS X'
    }
    def render
      rendered_authors = authors && authors.map do |name, _|
        %{<a href="javascript:pickyClient.insert('#{name.gsub(/[']/, '\\\\\'')}')">#{name}</a>}
      end
      rendered_authors = oxfordify rendered_authors
      
      rendered_subspecs = subspecs.map(&:name).join(', ')
      
      rendered_platform = @@platform_mapping[platforms.first] if platforms.count == 1
      rendered_platform = %Q{<div class="os">#{rendered_platform} only</div>} if rendered_platform
      pod_spec          = "pod '#{id}', '~&gt; #{version}'"
      %Q{<li class="result">#{rendered_platform}<h3><a href="#{link}">#{id}</a>#{version}</h3><span class="pod_spec" data-text="Copy pod spec">#{pod_spec}</span> <span class="clippy">#{pod_spec}</span><p class="subspecs">#{rendered_subspecs}</p><p>#{summary}</p><p class="author">#{rendered_authors}</p></li>}
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
