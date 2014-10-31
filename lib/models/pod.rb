require 'json'

# Only for reading purposes.
#
class Pod
  
  attr_reader :row
  
  extend Forwardable
  
  # Forward entities.
  #
  def_delegators :row, :pod, :versions, :commits
  
  # Forward attributes.
  #
  def_delegators :pod, :id, :name
  
  def initialize row
    @row = row
  end

  def self.entity
    Domain.pods
  end
  
  # Use e.g. Pod.find.where(…).all
  #
  def self.find
    entity.
      join(Domain.versions).on(Domain.pods[:id] => Domain.versions[:pod_id]).
      project(
        *Domain.pods.fields,
        'array_agg(pod_versions.name) AS versions'
      ).
      group_by(Domain.pods[:id])
  end
  
  #
  #
  def self.all
    yield(find).map(&modelify_block)
  end
  
  def self.modelify_block
    ->(pod) { new pod }
  end

  # Index specific methods.
  #

  def mapped_name
    split_name.join ' '
  end

  def mapped_versions
    versions.gsub(/[\{\}]/, '').split(',')
  end
  
  def last_version
    mapped_versions.
      sort_by { |v| Gem::Version.new(v) }.
      last
  end
  
  def authors
    specification['authors'] || {}
  end
  
  def mapped_authors
    spec_authors = authors
    spec_authors && spec_authors.keys.join(' ') || ''
  rescue StandardError, SyntaxError
    ''
  end
  
  def dependencies
    specification['dependencies'].keys
  end
  
  def mapped_dependencies
    dependencies.join ' '
  rescue StandardError, SyntaxError
    ''
  end
  
  def homepage
    specification['homepage']
  end
  
  def platforms
    (specification['platforms'] || {}).keys
  rescue
    specification['platforms']
  end
  
  def mapped_platform
    platforms.join(' ')
  rescue StandardError, SyntaxError
    '' # i.e. never found.
  end
  
  def summary
    (specification['summary'] || [])[0..139]
  end
  
  def source
    specification['source'] || {}
  end
  
  def recursive_subspecs
    []
  end
  
  # Summary with words already contained in
  # name removed such as to minimize
  # multiple results.
  #
  def mapped_summary
    summary
  rescue StandardError, SyntaxError
    ''
  end
  
  def documentation_url
    specification['documentation_url']
  end
  
  # Just load the latest specification data.
  #
  def specification_json
    result = Domain.commits.
      join(Domain.versions).on(Domain.commits[:pod_version_id] => Domain.versions[:id]).anchor.
      join(Domain.pods).on(Domain.versions[:pod_id] => Domain.pods[:id]).hoist.
      project(*Domain.commits[:specification_data]).
      where(
        Domain.pods[:id] => id,
        Domain.versions[:name] => last_version
      ).
      limit(1).
      order_by(Domain.commits[:pod_version_id]).
      first
    result.commit.specification_data if result
  end

  def specification
    JSON.parse(specification_json || '{}')
  end
  
  def deprecated_in_favor_of
    specification[:deprecated_in_favor_of]
  end
  
  def deprecated?
    p specification
    specification[:deprecated]
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
    specification['summary'].downcase.scan(/\b(#{@@tags.join('|')})\w*\b/).flatten.uniq
  rescue StandardError, SyntaxError
    []
  end
  
  def to_h
    h = {
      :id => name, # We don't hand out ids.
      :platforms => platforms,
      :version => last_version,
      :summary => mapped_summary,
      :authors => authors,
      :link => homepage.to_s,
      :source => source,
      :subspecs => recursive_subspecs.map(&:to_s),
      :tags => tags.to_a,
      :deprecated => deprecated?,
      :deprecated_in_favor_of => deprecated_in_favor_of
    }
    h[:documentation_url] = pod.documentation_url if pod.documentation_url
    h
  end
  
end
