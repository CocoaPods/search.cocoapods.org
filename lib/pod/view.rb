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
      rendered_authors = authors && authors.map do |name, email|
        %Q{<a href="mailto:#{email}">#{name}</a>}
      end
      case rendered_authors.size
      when 1
        rendered_authors = rendered_authors.first
      when 2
        rendered_authors = rendered_authors.join(' and ')
      else
        rendered_authors = "#{rendered_authors[0..-2].join(', ')}, and #{rendered_authors.last}"
      end
      %Q{<div class="pod"><h3 class="name">#{id}</h3><div class="version">#{version}</div><div class="summary"><p>#{summary}</p></div><div class="authors">#{rendered_authors}</div><div class="homepage"><a href="#{link}">#{link}</a></div></div>}
    end

  end
end
