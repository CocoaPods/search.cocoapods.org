require 'json'

# Only for reading purposes.
#
class Pod
  attr_reader :row

  extend Forwardable

  # Forward entities.
  #
  def_delegators :row,
                 :id,
                 :name,
                 :versions,
                 :commits,
                 :github_metric

  def initialize(row)
    @row = row
  end

  def self.entity
    Domain.pods
  end

  # Use e.g. Pod.find.where(…).all
  #
  def self.find
    entity.
      join(Domain.versions).
      on(Domain.pods[:id] => Domain.versions[:pod_id]).
      join(Domain.github_metrics).
      on(Domain.pods[:id] => Domain.github_metrics[:pod_id]).
      where(Domain.pods[:deleted] => false).
      project(
        *Domain.pods.fields,
        'array_agg(pod_versions.name) AS versions',
        <<-EXPR,
        (
          github_pod_metrics.contributors * 90 +
          github_pod_metrics.subscribers * 20 +
          github_pod_metrics.forks * 10 +
          github_pod_metrics.stargazers
        ) AS popularity
        EXPR
        *Domain.github_metrics.fields(:forks, :stargazers, :contributors, :subscribers),
      ).
      group_by(
        Domain.pods[:id],
        *Domain.github_metrics.fields(:forks, :stargazers, :contributors, :subscribers),
      )
  end

  #
  #
  def self.all
    yield(find).map(&modelify_block)
  rescue PG::UnableToSend
    STDOUT.puts 'PG::UnableToSend raised! Reconnecting to database.'
    load 'lib/database.rb'
    retry
  end

  def self.modelify_block
    ->(pod) { new pod }
  end

  # Sort specific methods
  #

  def popularity
    row.popularity || 0
  end

  def forks
    github_metric.forks || 0
  end

  def stargazers
    github_metric.stargazers || 0
  end

  def contributors
    github_metric.contributors || 0
  end

  def subscribers
    github_metric.subscribers || 0
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
    if spec_authors
      if spec_authors.respond_to? :to_hash
        spec_authors.keys.join(' ') || ''
      else
        if spec_authors.respond_to? :to_ary
          spec_authors.join(' ')
        else
          spec_authors
        end
      end
    else
      ''
    end
  rescue StandardError, SyntaxError
    spec_authors
  end

  def rendered_authors
    if authors.respond_to? :to_hash
      authors
    else
      [*authors].inject({}) do |result, name|
        result.tap { |r| r[name] = '' }
      end
    end
  end

  def dependencies
    [*recursive_subspecs, specification].
      map { |spec| spec['dependencies'] }.compact.
      flat_map { |deps| deps.respond_to?(:keys) ? deps.keys : deps }.
      map { |dependency| dependency.split('/', 2).first }.  # Strips subspec (QueryKit/Attribute)
      uniq.reject { |dependency| dependency == specification['name'] } # Remove current spec, might be used to depend on subspecs
  end

  def frameworks
    [*recursive_subspecs, specification].
      flat_map { |spec| spec['frameworks'] }.
      compact.uniq
  end

  def mapped_dependencies
    (dependencies + frameworks + recursive_subspec_names).join ' '
  rescue StandardError, SyntaxError
    ''
  end

  def homepage
    specification['homepage']
  rescue StandardError, SyntaxError
  end

  DEFAULT_PLATFORMS = [:osx, :ios]
  def platforms
    platforms_spec = specification['platforms']
    if platforms_spec.respond_to?(:to_hash)
      platforms_spec.keys
    else
      DEFAULT_PLATFORMS
    end
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
    mapper = lambda do |spec|
      spec['subspecs'].flat_map do |subspec|
        [subspec, *mapper.call(subspec)]
      end if spec['subspecs']
    end

    mapper.call(specification) || []
  end

  def recursive_subspec_names
    recursive_subspecs.map { |ss| ss['name'] }.compact
  end

  # Perhaps TODO: Summary with words already contained in
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
             join(Domain.versions).
             on(Domain.commits[:pod_version_id] => Domain.versions[:id]).
             anchor.
             join(Domain.pods).
             on(Domain.versions[:pod_id] => Domain.pods[:id]).
             hoist.
             project(*Domain.commits[:specification_data]).
             where(
        Domain.pods[:id] => id,
        Domain.versions[:name] => last_version,
      ).
             limit(1).
             order_by(Domain.commits[:pod_version_id]).
             first
    result.commit.specification_data if result
  end

  # TODO: Clear after using the specification.
  #       with_specification do ?
  #
  # Caching the specification speeds up indexing considerably.
  #
  def specification
    @specification ||= JSON.parse(specification_json || '{}')
  end

  def deprecated_in_favor_of
    specification[:deprecated_in_favor_of]
  end

  def deprecated?
    specification[:deprecated] == true
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
      *name.split(/([A-Z]?[a-z]+)/),
    ].compact.map(&:downcase).uniq.map(&:freeze)
  end

  # This is to provide helpful suggestions on long words.
  #
  def split_name_for_automatic_splitting
    temp = name
    if temp
      if temp.match(/\A[A-Z]{3}[a-z]/)
        temp = temp[2..-1]
      end
      parts = temp && temp.split(/([A-Z]?[a-z]+)/).map(&:downcase) || []
      parts.reject { |part| part.size < 3 }
    else
      []
    end
  end

  # Tag extracted from summary.
  #
  # Note: http://search.cocoapods.org/api/v1/pods.facets.json?include=name&only=name&at-least=30
  #
  TAGS = %w(
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
  ).freeze
  def tags
    specification['summary'].
      downcase.
      scan(/\b(#{TAGS.join('|')})\w*\b/).
      flatten.
      uniq
  rescue StandardError, SyntaxError
    []
  end

  def to_h
    # Was:
    #
    # @view[id] = {
    #   :id => id,
    #   :platforms => specification.available_platforms.map(&:name).to_a,
    #   :version => set.versions.first.to_s,
    #   :summary => specification.summary[0..139].to_s,
    #     # Cut down to 140 characters. TODO: Duplicated code. See set.rb.
    #   :authors => specification.authors.to_hash,
    #   :link => specification.homepage.to_s,
    #   :source => specification.source.to_hash,
    #   :subspecs => specification.recursive_subspecs.map(&:to_s),
    #   :tags => set.tags.to_a,
    #   :deprecated => specification.deprecated?,
    #   :deprecated_in_favor_of => specification.deprecated_in_favor_of
    # }
    @h ||= begin
      h = {
        id: name, # We don't hand out ids.
        platforms: platforms,
        version: last_version,
        summary: mapped_summary[0..139],
        authors: rendered_authors,
        link: homepage.to_s,
        source: source,
        tags: tags.to_a,
        deprecated: deprecated?,
        deprecated_in_favor_of: deprecated_in_favor_of,
      }
      h[:documentation_url] = row.documentation_url if row.respond_to?(:documentation_url)
      h
    end
  end
end
