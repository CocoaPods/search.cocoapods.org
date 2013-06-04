# Load the spec loader that gets the specs from github.
#
require File.expand_path '../pods/specs', __FILE__

class Pods
  
  attr_reader :path, :specs
  
  def initialize pods_path
    @path = pods_path
    @specs = {}
  end
  
  def sets
    Pod::Source.new(path).pod_sets
  end
  
  def prepare force = false
  
    # Getting the data.
    #
    specs = Specs.new
    if force || specs.empty?
      specs.get
      specs.prepare
    end
  
    # Content to render.
    #
    sets.each do |set|
      begin
        id      = set.name.dup
        version = set.versions.first
    
        specification = set.specification
        platforms     = specification.available_platforms.map(&:name)
        summary       = specification.summary[0..139] # Cut down to 140 characters. TODO Duplicated code. See set.rb.
        authors       = specification.authors
        link          = specification.homepage
        subspecs      = specification.recursive_subspecs
      
        # Picky is destructive with the given data
        # strings, which is why we dup the content
        # to render.
        #
        Pod::View.update(id,
                         platforms,
                         version && version.dup,
                         summary && summary.dup,
                         authors && authors.dup,
                         link    && link.dup,
                         subspecs)
      
        @specs[set.name] = set.specification
      rescue StandardError, SyntaxError => e# Yes, people commit pod specs with SyntaxErrors
        puts e.message
        next # Skip this pod.
      end
    end
  end
  
end