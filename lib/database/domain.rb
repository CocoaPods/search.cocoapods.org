# frozen_string_literal: true
# Defines the domain.
#
Object.send :remove_const, :Domain if defined? Domain
Domain = Flounder.domain(DB) do |dom|
  dom.entity(:commits, :commit, 'commits')
  dom.entity(:pods, :pod, 'pods')
  dom.entity(:versions, :version, 'pod_versions')
  dom.entity(:github_metrics, :github_metric, 'github_pod_metrics')
  dom.entity(:cocoadocs_pod_metrics, :cocoadocs_pod_metric, 'cocoadocs_pod_metrics')
end

# Define all tables as top-level methods on Domain.
#
Domain.entities.each do |entity|
  Domain.define_singleton_method entity.name do
    entity
  end
end

require File.expand_path '../../models/pod', __FILE__
