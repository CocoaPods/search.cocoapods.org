require File.expand_path '../commit', __FILE__

# Only for reading purposes.
#
class Version < Sequel::Model(:pod_versions)
  many_to_one :pod
  one_to_many :commits, :key => :pod_version_id
end
