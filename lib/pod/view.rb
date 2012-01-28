module Pod

  # "View" class to render results with.
  #
  class View
    
    # The view content.
    #
    # A hash of
    #   id => [version, summary, authors, link]
    #
    def self.content
      @content ||= {}
    end

    # Stub.
    #
    def self.find ids, options = {}
      ids.map do |id|
        new id, *content[id]
      end
    end

    attr_reader :id,
                :version,
                :summary,
                :authors,
                :link

    def initialize id, version, summary, authors, link
      @id, @version, @summary, @authors, @link = id, version, summary, authors, link
    end

    def render
      rendered_authors = authors.map do |name, email|
        %Q{<a href="mailto:#{email}">#{name}</a>}
      end.join ' and '
      %Q{<div><h3 class="name">#{id}</h3><div class="version">#{version}</div><div class="summary"><p>#{summary}</p></div><div class="authors">#{rendered_authors}</div><div class="homepage"><a href="http://github.com/CocoaPods/Specs/tree/master/#{id}">Homepage</a></div></div>}
    end

  end
end