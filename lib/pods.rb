class Pods
  
  # TODO Remove specs ASAP.
  #
  attr_reader :path, :view, :specs
  
  def initialize pods_path
    @path  = pods_path
    @view  = {}
    @specs = {}
    @view_dump_file = File.join Picky.root, 'view.dump'
  end
  
  # Pods are ordered by name.
  #
  def each &block
    Pod.order(:name).each &block
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
    each do |pod|
      id            = pod.name.dup.to_s
      specification = pod.specification

      # Picky is destructive with the given data
      # strings, which is why we dup the content
      # to render.
      #
      @view[id] = {
        :id => id,
        :platforms => specification.available_platforms.map(&:name).to_a,
        :version => pod.versions.first.to_s,
        :summary => specification.summary[0..139].to_s, # Cut down to 140 characters. TODO Duplicated code. See set.rb.
        :authors => specification.authors.to_hash,
        :link => specification.homepage.to_s,
        :source => specification.source.to_hash,
        :subspecs => specification.recursive_subspecs.map(&:to_s),
        :tags => pod.tags.to_a
      }
      documentation_url = specification.documentation_url
      @view[id][:documentation_url] = documentation_url if documentation_url
      
      # TODO Remove ASAP.
      #
      @specs[pod.name] = specification
    end
  end
  
  def load
    if File.exists? @view_dump_file
      File.open @view_dump_file, 'r' do |file|
        @view = Marshal.load file
      end
    end
  end
  
  def dump
    File.open @view_dump_file, 'w' do |file|
      Marshal.dump @view, file
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