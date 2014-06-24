require File.expand_path '../version', __FILE__

# Only for reading purposes.
#
class Pod < Sequel::Model(:pods)
  one_to_many :versions

  # Index specific methods.
  #

  def id
    name
  end

  def mapped_name
    split_name.join ' '
  end

  def mapped_versions
    versions.map &:name
  end
  
  def mapped_authors
    spec_authors = specification.authors
    spec_authors && spec_authors.keys.join(' ') || ''
  rescue Pod::Informative, StandardError, SyntaxError
    ''
  end
  
  def mapped_dependencies
    specification.dependencies.map(&:name).join ' '
  rescue Pod::Informative, StandardError, SyntaxError
    ''
  end
  
  def mapped_platform
    specification.available_platforms.map(&:name).sort.join(' ')
  rescue Pod::Informative, StandardError, SyntaxError
    '' # i.e. never found.
  end
  
  # Summary with words already contained in
  # name removed such as to minimize
  # multiple results.
  #
  def mapped_summary
    specification.summary[0..139]
  rescue Pod::Informative, StandardError, SyntaxError
    ''
  end
  
  def specification_json
    # TODO: Also sort Commits correctly.
    #
    version = versions.sort_by { |v| Gem::Version.new(v.name) }.last
    commit = version.commits.last if version
    commit.specification_data if commit
  end

  def specification
    JSON.parse(specification_json || '{}')
  end
  
  
  # Returns not just the name, but also:
  #  * Separated uppercase/lowercase parts.
  #  * Name without initials.
  #
  def split_name
    first, *rest = name.split(/\b/)
    initials, after_initials = first.split(/(?=[A-Z][a-z])/, 2)
    [
      name,
      initials,
      after_initials,
      first,
      *rest,
      *name.split(/([A-Z]?[a-z]+)/)
    ].compact.map(&:downcase).uniq.map(&:freeze)
  end
  
  # This is to provide helpful suggestions on long words.
  #
  def split_name_for_automatic_splitting
    temp = name
    if temp
      if temp.match /\A[A-Z]{3}[a-z]/
        temp = temp[2..-1]
      end
      (temp && temp.split(/([A-Z]?[a-z]+)/).map(&:downcase) || []).reject do |part|
        part.size < 3
      end
    else
      []
    end
  end
  
  # Tag extracted from summary.
  #
  # Note: http://search.cocoapods.org/api/v1/pods.facets.json?include=name&only=name&at-least=30
  #
  @@tags = %w{
    alert
    analytics
    api
    authentication
    button
    client
    communication
    controller
    gesture
    http
    image
    json
    kit
    layout
    logging
    manager
    navigation
    network
    notification
    parser
    password
    payment
    picker
    progress
    rest
    serialization
    table
    test
    text
    view
    widget
    xml
  }
  def tags
    specification.summary.downcase.scan(/\b(#{@@tags.join('|')})\w*\b/).flatten.uniq
  rescue Pod::Informative, StandardError, SyntaxError
    []
  end
  
end
