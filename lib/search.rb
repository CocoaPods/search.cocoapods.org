class Search
    
  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky

  attr_reader :index, :interface, :splitter

  def initialize pods
    @pods = pods
    
    @facet_keys = [:tags, :platform, :version]
    
    # http://nlp.stanford.edu/IR-book/html/htmledition/dropping-common-terms-stop-words-1.html
    #
    # "it" is a prefix but we still stopword it.
    # We do not stop "on" as it is used for qualifying the platform.
    #
    stopwords = /\b(a|an|are|as|at|be|by|for|from|has|he|in|is|it|its|of|that|the|to|was|were|will|with)\b/i
  
    # Set up similarity configurations.
    #
    few_similars = Similarity::DoubleMetaphone.new 2
    
    # Set up partial configurations.
    #
    no_partial   = Partial::None.new
    full_partial = Partial::Substring.new(from: 1)
  
    # Define an index.
    #
    @index = Index.new :pods do
      
      # Use the cocoapods-specs repo for the data.
      #
      source { pods.sets }
      
      # We use the pod names as ids (as strings).
      #
      key_format :to_s

      indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
               stopwords:          stopwords,
               splits_text_on:     /[\s\/\-\_\:\"\&\/]/,
               rejects_token_if:   lambda { |token| token.size < 2 }
      
      # Note: Add more categories.
      #
      category :name,
               similarity: few_similars,
               partial: full_partial,
               qualifiers: [:name, :pod],
               :from => :mapped_name,
               :indexing => {
                 removes_characters: //,      # We don't remove any characters.
                 splits_text_on:     /[\s\-]/ # We split on fewer characters.
               }
      category :author,
               similarity: few_similars,
               partial: full_partial,
               qualifiers: [:author, :authors, :written, :writer, :by],
               :from => :mapped_authors,
               :indexing => {
                 # Some names have funky characters. Let's normalize.
                 #
                 substitutes_characters_with: CharacterSubstituters::WestEuropean.new
               }
      category :version,
               partial: full_partial,
               :from => :mapped_versions
      category :dependencies,
               similarity: few_similars,
               partial: no_partial, # full_partial,
               qualifiers: [:dependency, :dependencies, :depends, :using, :uses, :use, :needs],
               :from => :mapped_dependencies
      category :platform,
               partial: no_partial,
               qualifiers: [:platform, :on],
               :from => :mapped_platform
      category :summary,
               partial: no_partial, # full_partial,
               :from => :mapped_summary,
               :indexing => {
                 removes_characters: /[^a-z0-9\s\-]/i # We remove special characters.
               }
      category :tags,
               partial: no_partial,
               qualifiers: [:tag, :tags],
               tokenize: false
    end
  
    # Define a search over the books index.
    #
    @interface = Search.new index do
      searching substitutes_characters_with: CharacterSubstituters::WestEuropean.new, # Normalizes special user input, Ä -> Ae, ñ -> n etc.
                removes_characters: /[^a-z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
                stopwords:          stopwords,
                splits_text_on:     /[\s\/\-\&]+/

      boost [:name, :author]  => +2,
            [:name]           => +3,
            [:tags]           => +1,
            [:tags, :name]    => +2,
            [:name, :tags]    => +2,
            [:name, :summary] => -3,
            [:summary]        => -3,
            [:dependencies]   => -4,
            [:platform, :name, :author]  => +2,
            [:platform, :name]           => +3,
            [:platform, :tags]           => +1,
            [:platform, :tags, :name]    => +2,
            [:platform, :name, :tags]    => +2,
            [:platform, :name, :summary] => -3,
            [:platform, :summary]        => -3,
            [:platform, :dependencies]   => -4
    end
    
    @splitting_index = Index.new :splitting do
      
      # Use the cocoapods-specs repo for the data.
      #
      source { pods.sets }
      
      # We use the pod names as ids (as strings).
      #
      key_format :to_s

      # TODO We need to work on this. This is still the Picky standard.
      #
      indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
               stopwords:          stopwords,
               splits_text_on:     /[\s\/\-\_\:\"\&\/]/,
               rejects_token_if:   lambda { |token| token.size < 2 }

      # Note: Add more categories.
      #
      category :split,
               partial: no_partial,
               tokenize: false,
               :from => :split_name_for_automatic_splitting
    end
    
    @splitter = Picky::Splitters::Automatic.new @splitting_index[:split]
  
  end
  
  def reindex force = false
    @index.clear
    @splitting_index.clear
    
    # If we don't do this, Ruby will continue grabbing more and more memory.
    #
    GC.start full_mark: true, immediate_sweep: true
    
    @pods.prepare force
    
    @index.reindex
    @splitting_index.reindex
    
    @pods.reset
    
    # If we don't do this, Ruby will continue grabbing more and more memory.
    #
    GC.start full_mark: true, immediate_sweep: true
  end
  
  def load
    @index.load
    @pods.load
  end
  
  def dump
    @index.dump
    @pods.dump
  end
  
  def facets options = {}
    @facet_keys.inject({}) do |result, key|
      result[key] = @interface.facets key, options
      result
    end
  end
  
end