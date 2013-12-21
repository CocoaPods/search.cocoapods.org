module Pod

  # "View" class to render results with.
  #
  class View < Struct.new(:id, :platforms, :version, :summary, :authors, :link, :source, :subspecs, :tags, :documentation_url)
    
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
    def self.update id, *args
      content[id] = new id, *args
    end

    # Stub find method coverts result ids into
    # an array of View models.
    #
    # Note: Picky calls this method from its
    # Results#populate_with method.
    #
    def self.find_all_by_id ids, options = {}
      ids.map { |id| content[id] }
    end
    
    # Renders a result for display
    # in the Picky front end.
    #
    @@platform_mapping = {
      :ios  => 'iOS',
      :osx  => 'OS X'
    }
    
    # TODO Remove.
    #
    def to_html
      rendered_authors = authors && authors.map do |name, _|
        %{<a href="javascript:pickyClient.insert('#{name.gsub(/[']/, '\\\\\'')}')">#{name}</a>}
      end
      rendered_authors = oxfordify rendered_authors
      
      rendered_subspecs = subspecs.map(&:name).join(', ')
      
      rendered_platform = @@platform_mapping[platforms.first] if platforms.count == 1
      rendered_platform = %Q{<span class="os">#{rendered_platform} only</span>} if rendered_platform
      pod_spec          = "pod '#{id}', '~&gt; #{version}'"
      pod_spec_url      = "https://github.com/CocoaPods/Specs/tree/master/#{id}"
      
<<-POD
<li class="result">
  <div class="infos">
    <h3>
      <a href="#{link}">#{id}</a>
      #{rendered_platform}
      <span class="version">
        #{version}
        <span class="clippy">#{pod_spec}</span>
      </span>
    </h3>
    <p class="subspecs">#{rendered_subspecs}</p>
    <p>#{summary}</p>
    <p class="author">#{rendered_authors}</p>
  </div>
  <div class="actions">
    <a href="http://cocoadocs.org/docsets/#{id}/#{version}">Docs</a>
    <a href="#{link}">Repo</a>
    <a href="#{pod_spec_url}">Spec</a>
  </div>
</li>
POD
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

    # temporary for API 1.5 
    #
    # TODO Remove ASAP.
    #
    def render_short_json
      {
        "id" => id,
        "summary" => summary,
        "version" => version
      }
    end
    
    def to_hash
      result = {
        :id => id,
        :platforms => platforms,
        :version => version,
        :summary => summary,
        :authors => authors,
        :link => link,
        :source => source,
        :subspecs => subspecs,
        :tags => tags
      }
      result[:documentation_url] = documentation_url if documentation_url
      result
    end
    
    def to_json
      to_hash.to_json
    end

  end
end
