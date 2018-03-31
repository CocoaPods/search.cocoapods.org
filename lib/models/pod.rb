# frozen_string_literal: true
require 'json'

# Only for reading purposes.
#
class Pod
  attr_reader :row, :versions

  DEFAULT_QUALITY = 40

  EMPTY_STRING = ''

  extend Forwardable

  # Forward entities.
  #
  def_delegators :row,
                 :id,
                 :name,
                 # :versions,
                 :commits,
                 :github_metric,
                 :cocoadocs_pod_metric

  def initialize(row)
    preprocess row
    @row = row # Note: We explicitly nil-ify the row after we have used it.
  end
  # Specifically extract some row data.
  #
  def preprocess row
    return unless row.respond_to?(:versions)

    versions = row.versions
    @versions = if versions
      versions.gsub(/[\{\}]/, '').split(',').map(&:freeze)
    else
      []
    end
  end

  def self.entity
    Domain.pods
  end

  def self.count
    entity.count
  end

  # Use e.g. Pod.find.where(…).all
  #
  def self.find
    pods = entity.
      join(Domain.versions).
      on(Domain.pods[:id] => Domain.versions[:pod_id]).

      join(Domain.github_metrics).
      on(Domain.pods[:id] => Domain.github_metrics[:pod_id]).

      outer_join(Domain.cocoadocs_pod_metrics).
      on(Domain.pods[:id] => Domain.cocoadocs_pod_metrics[:pod_id]).

      where(Domain.pods[:deleted] => false).

      project(
        *Domain.pods.fields(:id, :name),
        'array_agg(pod_versions.name) AS versions',
        <<-EXPR,
        (
          github_pod_metrics.contributors * 90 +
          github_pod_metrics.subscribers * 20 +
          github_pod_metrics.forks * 10 +
          github_pod_metrics.stargazers
        ) AS popularity
        EXPR
        *Domain.github_metrics.fields(:forks, :stargazers, :contributors, :subscribers, :language),
        *Domain.cocoadocs_pod_metrics.fields(:id, :dominant_language, :quality_estimate)
      ).

      group_by(
        Domain.pods[:id],
        *Domain.github_metrics.fields(:forks, :stargazers, :contributors, :subscribers, :language),
        *Domain.cocoadocs_pod_metrics.fields(:id, :dominant_language, :quality_estimate)
      )

    # Possibly filter prerelease pods & prerelease versions.
    pods.where("pod_versions.name !~ E'[a-zA-Z]'") if released_only?

    pods
  end

  # Returns true if only released pods are to be shown, false otherwise.
  #
  def self.released_only?
    ENV['RELEASED_PODS_ONLY']
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

  def quality
    cocoadocs_pod_metric.quality_estimate || DEFAULT_QUALITY
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

  def language
    github_metric.language
  end

  def dominant_language
    cocoadocs_pod_metric.dominant_language
  end

  # Index specific methods.
  #

  def mapped_name
    split_name.join(' ')
  end

  # Currently only two languages are available for filtering.
  #
  @@objc_lang = ['objc']
  @@swift_lang = ['swift']
  @@language_map = {
    "Objective C" => @@objc_lang,
    "Swift" => @@swift_lang
  }
  @@language_map.default = @@objc_lang
  def mapped_language
    @@language_map[dominant_language || language]
  end

  # Symbolized as there are likely duplicates.
  #
  def last_version
    versions.
      sort_by { |v| Gem::Version.new(v) }.
      last.to_sym
  end

  def authors
    specification[:authors] || {}
  end

  def mapped_authors
    spec_authors = authors
    if spec_authors
      if spec_authors.respond_to? :to_hash
        spec_authors.keys.join(' ') || :''
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

  # We could optimise by not sending out the email addres,
  # or by splitting it into an array of ["a", "b.com"].
  #
  def rendered_authors
    if authors.respond_to? :to_hash
      symbolize_hash(authors)
    else
      [*authors].inject({}) do |result, name|
        if name.respond_to? :to_hash
          symbolize_hash(name)
        else
          result.tap { |r| r[name.to_sym] = EMPTY_STRING }
        end
      end
    end
  end
  def symbolize_hash hash
    hash.inject({}) do |result, (key, value)|
      if value.kind_of?(Array) || value.kind_of?(Hash) || key.kind_of?(Array)
        puts "Issue with: #{key} - #{value}"
        result
      else
        result.tap { |r| r[key.to_sym] = (value && value.to_sym) }
      end
    end
  end

  def dependencies
    [*recursive_subspecs, specification].
      map { |spec| spec[:dependencies] }.compact.
      flat_map { |deps| deps.respond_to?(:keys) ? deps.keys : deps }.
      map { |dependency| dependency.to_s.split('/', 2).first }.  # Strips subspec (QueryKit/Attribute)
      uniq.reject { |dependency| dependency == specification[:name] } # Remove current spec, might be used to depend on subspecs
  end

  def frameworks
    [*recursive_subspecs, specification].
      flat_map { |spec| spec[:frameworks] }.
      compact.uniq
  end

  def mapped_dependencies
    (dependencies + frameworks).join ' '
  rescue StandardError, SyntaxError
    ''
  end

  def mapped_subspec_names
    recursive_subspecs.map { |ss| ss[:name] }.join(' ')
  end

  def homepage
    specification[:homepage]
  rescue StandardError, SyntaxError
  end

  DEFAULT_PLATFORMS = [:osx, :ios]
  def platforms
    platforms_spec = specification[:platforms]
    if platforms_spec.respond_to?(:to_hash)
      # Symbolized as there are likely duplicates.
      #
      platforms_spec.keys.map(&:to_sym)
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
    (specification[:summary] || [])[0..139]
  end

  def source
    (specification[:source] || {}).inject({}) do |result, (type, target)|
      # TODO Strip tag? (and others)
      # next result if type == 'tag'
      result.tap { |r| r[type.to_sym] = target }
    end
  end

  def recursive_subspecs
    mapper = lambda do |spec|
      spec[:subspecs].flat_map do |subspec|
        [subspec, *mapper.call(subspec)]
      end if spec[:subspecs]
    end

    mapper.call(specification) || []
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
    specification[:documentation_url]
  end

  def cocoadocs?
    !!cocoadocs_pod_metric.id
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
               Domain.versions[:name] => last_version.to_s, # TODO This is a bit silly.
             ).

             limit(1).

             order_by(
               Domain.commits[:created_at].desc,
             ).

             first
    result.commit.specification_data if result
  end

  # Caching the specification speeds up indexing considerably.
  #
  def specification
    @specification ||= JSON.parse(specification_json || '{}', symbolize_names: true)
  end
  # Use to GC e.g. the specification after having used it.
  #
  def release_indexing_memory
    @specification = nil
  end

  def deprecated_in_favor_of
    specification[:deprecated_in_favor_of]
  end

  # A pod is either explicitly deprecated or
  # implicitly, in favor of another pod.
  #
  def deprecated?
    specification[:deprecated] == true || !!deprecated_in_favor_of
  end

  # Returns not just the name, but also:
  #  * Separated uppercase/lowercase parts.
  #  * Name without initials.
  #
  def split_name
    head, *tail = name.split(/\b/)
    # If 5 or more are uppercase characters, split off the first 2.
    if head =~ /\A[A-Z]{5,}.*?\z/
      initials1, head = head.split(/\A([A-Z]{2})(.+)/)[1..2]
    end
    initials2, after_initials = head.split(/(?=[A-Z][a-z])/, 2)
    [
      name,
      initials1,
      initials2,
      after_initials,
      head,
      *tail,
      *name.split(/([A-Z]?[a-z]+)/),
    ].compact.map(&:downcase).uniq.map(&:freeze)
  end

  # This is to provide helpful suggestions on long words.
  #
  def split_name_for_automatic_splitting
    temp = name
    if temp
      if temp =~ /\A[A-Z]{3}[a-z]/
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
  tags = %w(
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
    ssh
    table
    test
    text
    view
    widget
    xml
  ).map(&:freeze).freeze
  TAGS_REGEX = /\b(#{tags.join('|')})\w*\b/
  def tags
    specification[:summary].
      downcase.
      scan(TAGS_REGEX).
      flatten.
      uniq.map(&:to_sym)
  rescue StandardError, SyntaxError
    []
  end

  def reduce_memory_usage
    # Render
    to_h
    # Throw the row and spec away if this pod has been rendered.
    @row = nil
    @versions = nil
    @specification = nil
  end

  # Throws the row away.
  #
  def to_h
    @h ||= begin
      rendered_homepage, rendered_source = compress

      # Create a rendered hash.
      h = {
        id: name, # We don't hand out ids.
        platforms: platforms,
        version: last_version,
        summary: mapped_summary[0..139],
        authors: rendered_authors,
        link: rendered_homepage,
        source: rendered_source,
        tags: tags,
      }

      if deprecated?
        h[:deprecated] = true
        h[:deprecated_in_favor_of] = deprecated_in_favor_of
      end
      h[:documentation_url] = row.documentation_url if row.respond_to?(:documentation_url)
      h[:cocoadocs] = true if cocoadocs?

      h
    end

    # Each render, uncompress.
    #
    uncompress @h
  end

  def compress
    rendered_homepage = homepage
    if rendered_homepage =~ /github\.com/
      rendered_homepage = split_github(rendered_homepage)
    end

    # Small memory optimisation.
    # We could use Symbols, but most URLs are unique.
    rendered_source = source
    if rendered_source
      if rendered_homepage == rendered_source[:git]
        rendered_source[:git] = rendered_homepage
      else
        if rendered_source[:git] =~ /github\.com/
          rendered_source[:git] = split_github(rendered_source[:git])
        end
      end
    end

    [rendered_homepage, rendered_source]
  end
  def split_github url
    match = url.match(/(https?|git)/)
    protocol = match[0]
    (protocol = protocol.to_sym) if protocol
    part = url.gsub(%r{^((https?|git)://|git@)(www\.)?github.com/}, '')
    [protocol, :'github.com', part]
  end
  def uncompress hash
    link = hash[:link]
    source = hash[:source]
    if source
      if link.respond_to?(:to_ary)
        hash[:link] = [
          link[0],
          (link[0] == :git ? :'@' : :'://'),
          link[1],
          :/,
          link[2]
        ].join
      end
      source_link = source[:git]
      if source_link.respond_to?(:to_ary)
        source[:git] = uncompress_link(source_link)
      end
    end
    hash
  end
  def uncompress_link link
    [
      link[0],
      :'://',
      link[1],
      :/,
      link[2]
    ].join
  end
end
