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

    # temporary for API 1.5 
    #
    # TODO Remove ASAP.
    #
    def render_short_json
      {
        :id => id,
        :summary => summary,
        :version => version
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
