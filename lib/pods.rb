class Pods
  
  attr_reader :path, :specs
  
  def initialize pods_path
    @path = pods_path
    @specs = {}
  end
  
  def sets
    @sets ||= Pod::Source.new(path).pod_sets
  end
  
  def reset
    @sets = nil
  end
  
  def prepare force = false
  
    # Getting the data.
    #
    if force || empty?
      get
      unpack
      reset
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
        tags          = set.tags
      
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
                         subspecs,
                         tags)
      
        @specs[set.name] = set.specification
      rescue StandardError, SyntaxError => e# Yes, people commit pod specs with SyntaxErrors
        puts e.message
        next # Skip this pod.
      end
    end
  end
  
  # Are there any specs to index?
  #
  def empty?
    Dir['./tmp/specs/*'].empty?
  end

  # Gets the latest master specs from the Specs repo.
  #
  # Note: Overwrites the old specs.zip.
  #
  def get
    `curl -L -o ./tmp/specs.tar.gz http://github.com/CocoaPods/Specs/tarball/master`
  end

  # Prepares the specs for indexing.
  #
  def unpack
    `rm -rf ./tmp/specs`
    `gunzip -f ./tmp/specs.tar.gz`
    `cd tmp; tar xvf specs.tar`
    `mv -f ./tmp/CocoaPods-Specs-* ./tmp/specs`
  end
  
end