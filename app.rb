require 'sinatra/base'
require 'i18n'
require 'picky'
require 'picky-client'
require 'cocoapods'

# Extend Pod::Specification with the capability of ignoring bad specs.
#
require File.expand_path '../lib/pod/specification', __FILE__

# Extend Pod::Specification::Set with a few needed methods for indexing.
#
require File.expand_path '../lib/pod/specification/set', __FILE__

# Load a view proxy for dealing with "rendering".
#
require File.expand_path '../lib/pod/view', __FILE__

# This app shows how to integrate the Picky server directly
# inside a web app. However, if you really need performance
# and easy caching this is not recommended.
#
class CocoapodSearch < Sinatra::Application

  set :logging, false

  # Load the spec loader that gets the specs from github.
  #
  require File.expand_path '../lib/specs', __FILE__

  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky


  # Server.
  #
  
  pods_path = Pathname.new ENV['COCOAPODS_SPECS_PATH'] || './tmp/specs'

  # Define an index.
  #
  index = Index.new :pods do

    # Use the cocoapods-specs repo for the data.
    #
    source { Pod::Source.new(pods_path).pod_sets }

    # As a test, we use the pod names as ids
    # (symbols to enhance performance).
    #
    key_format :to_sym

    # TODO We need to work on this. This is still the Picky standard.
    #
    indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
             stopwords:          /\b(and|the|of|it|in|for)\b/i,
             splits_text_on:     /[\s\/\-\_\:\"\&\/]/

    # Note: Add more categories.
    #
    category :name,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:name, :pod],
             :from => :mapped_name
    category :author,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:author, :authors, :written, :writer, :by],
             :from => :mapped_authors
    category :version,
             partial: Partial::Substring.new(from: 1),
             :from => :mapped_versions
    category :dependencies,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:dependency, :dependencies, :depends, :using, :uses, :use, :needs],
             :from => :mapped_dependencies
    category :platform,
             partial: Partial::None.new,
             qualifiers: [:platform, :on],
             :from => :mapped_platform
    category :summary,
             partial: Partial::Substring.new(from: 1),
             :from => :mapped_summary
  end

  # Add class method to this class
  # which gets the specs if they are
  # not available and reindexes.
  #
  self.class.send :define_method, :prepare do |force = false|
    
    # Getting the data.
    #
    specs = Specs.new
    if force || specs.empty?
      specs.get
      specs.prepare
    end
    
    # Content to render.
    #
    Pod::Source.new(pods_path).pod_sets.each do |set|
      id      = set.name.dup
      version = set.versions.first
      
      specification = set.specification
      summary       = specification.summary
      authors       = specification.authors
      link          = specification.homepage
      
      # Picky is destructive with the given data
      # strings, which is why we dup the content
      # to render.
      #
      Pod::View.add(id,
                    version && version.dup,
                    summary && summary.dup,
                    authors && authors.dup,
                    link    && link.dup)
    end
    
    # Indexing the data.
    #
    index.reindex
    
  end

  # Define a search over the books index.
  #
  pods = Search.new index do
    searching substitutes_characters_with: CharacterSubstituters::WestEuropean.new, # Normalizes special user input, Ä -> Ae, ñ -> n etc.
              removes_characters: /[^a-z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/

    boost [:platform, :name, :author]  => +3,
          [:platform, :name]           => +2,
          [:platform, :name, :summary] => -3, # Summary is the least important.
          [:platform, :summary]        => -3  #
  end


  # Client.
  #

  set :static,        true
  set :public_folder, File.dirname(__FILE__)
  set :views,         File.expand_path('../views', __FILE__)

  ON_IOS = /(on|platform):ios/i
  ON_OSX = /(on|platform):osx/i

  # Root, the search page.
  #
  get '/' do
    @query = params[:q]

    # TODO: There is probably a query parser of Picky that could be used here.
    #
    if @query =~ ON_IOS && @query =~ ON_OSX
      @platform = :both
    elsif @query =~ ON_IOS
      @platform = :ios
    else
      @platform = :osx
    end

    erb :'/search'
  end

  # Renders the results into the json.
  #
  # You get the results from the (local) picky server and then
  # populate the result hash with rendered models.
  #
  get '/search' do
    results = pods.search params[:query], params[:ids] || 20, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    results.populate_with Pod::View do |pod|
      pod.render
    end
    Yajl::Encoder.encode results
  end

  # Install get and post hooks.
  #
  [:get, :post].each do |type|
    send type, "/post-receive-hook/#{ENV['HOOK_PATH']}" do
      begin
        self.class.prepare true

        status 200
        body "REINDEXED"
      rescue StandardError => e
        status 500
        body e.message
      end
    end
  end

  helpers do

    def js path
      "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
    end

  end

end
