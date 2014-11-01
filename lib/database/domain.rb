# Defines the domain.
#
Domain = Flounder.domain(DB) do |dom|
  dom.entity(:commits, :commit, 'commits')
  dom.entity(:pods, :pod, 'pods')
  dom.entity(:versions, :version, 'pod_versions')
end

# Define all tables as top-level methods on Domain.
#
Domain.entities.each do |entity|
  Domain.define_singleton_method entity.name do
    entity
  end
end

require File.expand_path '../../models/pod', __FILE__
