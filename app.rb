require 'sinatra/base'
require 'i18n'
require 'haml'
require 'picky'
require 'picky-client'

# Make autoloading work.
#
$:.unshift File.expand_path('../../cocoapods/lib/', __FILE__)
require 'cocoapods'

# Extend Pod::Specification::Set with a few needed methods for indexing.
#
require File.expand_path '../pod/specification/set', __FILE__

# Load a view proxy for dealing with "rendering".
#
require File.expand_path '../pod/view', __FILE__

# This app shows how to integrate the Picky server directly
# inside a web app. However, if you really need performance
# and easy caching, this is not recommended.
#
class CocoapodSearch < Sinatra::Application

  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky


  # Server.
  #

  # Define an index.
  #
  index = Index.new :pods do

    # Use the cocoapods-specs repo for the data.
    #
    source do
      path = Pathname.new '../cocoapods-specs'
      Pod::Source.new(path).pod_sets
    end

    # As a test, we use the pod names as ids.
    #
    key_format :to_sym

    # Note: We need to work on this.
    #
    indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
             stopwords:          /\b(and|the|of|it|in|for)\b/i,
             splits_text_on:     /[\s\/\-\_\:\"\&\/]/

    # Note: Add more categories.
    #
    category :name,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:name, :gem]
    category :author,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:author, :authors, :written, :writer, :by],
             :from => :mapped_authors
    category :version,
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:version],
             :from => :mapped_versions
    category :dependencies,
             similarity: Similarity::DoubleMetaphone.new(2),
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:dependency, :dependencies, :depends, :using, :uses, :use, :needs],
             :from => :mapped_dependencies
    category :platform,
             partial: Partial::Substring.new(from: 1),
             qualifiers: [:platform, :on],
             :from => :mapped_platform
  end

  # Index and load on USR1 signal.
  #
  Signal.trap('USR1') do
    books_index.reindex # kill -USR1 <pid>
  end

  # Define a search over the books index.
  #
  pods = Search.new index do
    searching substitutes_characters_with: CharacterSubstituters::WestEuropean.new, # Normalizes special user input, Ä -> Ae, ñ -> n etc.
              removes_characters: /[^a-z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/

    boost [:name, :author] => +3,
          [:name]          => +1
  end


  # Client.
  #

  set :static, true
  set :public, File.dirname(__FILE__)
  set :views,  File.expand_path('../views', __FILE__)
  set :haml,   :format => :html5

  # Root, the search page.
  #
  get '/' do
    @query = params[:q]

    haml :'/search'
  end

  # Configure. The configuration info page.
  #
  get '/configure' do
    haml :'/configure'
  end

  # Renders the results into the json.
  #
  # You get the results from the (local) picky server and then
  # populate the result hash with rendered models.
  #
  get '/search/full' do
    results = pods.search params[:query], params[:ids] || 20, params[:offset] || 0
    results = results.to_hash
    results.extend Picky::Convenience
    results.populate_with Pod::View do |pod|
      pod.to_s
    end

    #
    # Or, to populate with the model instances, use:
    #   results.populate_with Book
    #
    # Then to render:
    #   rendered_entries = results.entries.map do |book| (render each book here) end
    #

    ActiveSupport::JSON.encode results
  end

  # Updates the search count while the user is typing.
  #
  get '/search/live' do
    results = pods.search params[:query], params[:ids] || 20, params[:offset] || 0
    results.to_json
  end

  helpers do

    def js path
      "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
    end

  end

end