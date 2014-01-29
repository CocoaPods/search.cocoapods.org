class Search
    
  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky

  attr_reader :index, :interface, :splitter

  def initialize pods
    @pods = pods
    
    # http://nlp.stanford.edu/IR-book/html/htmledition/dropping-common-terms-stop-words-1.html
    #
    # "it" is a prefix but we still stopword it.
    # We do not stop "on" as it is used for qualifying the platform.
    #
    stopwords = /\b(a|an|are|as|at|be|by|for|from|has|he|in|is|it|its|of|that|the|to|was|were|will|with)\b/i
  
    # Define an index.
    #
    @index = Index.new :pods do
      
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
               rejects_token_if:   lambda { |token| token.size < 2 },
               substitutes_characters_with: CharacterSubstituters::WestEuropean.new

      few_similars = Similarity::DoubleMetaphone.new 2
      
      no_partial   = Partial::None.new
      full_partial = Partial::Substring.new(from: 1)
      
      # Note: Add more categories.
      #
      category :name,
               similarity: few_similars,
               partial: full_partial,
               qualifiers: [:name, :pod],
               :from => :mapped_name
      category :author,
               similarity: few_similars,
               partial: full_partial,
               qualifiers: [:author, :authors, :written, :writer, :by],
               :from => :mapped_authors
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
               :from => :mapped_summary
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

      # As a test, we use the pod names as ids
      # (symbols to enhance performance).
      #
      key_format :to_s

      # TODO We need to work on this. This is still the Picky standard.
      #
      indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
               stopwords:          stopwords,
               splits_text_on:     /[\s\/\-\_\:\"\&\/]/,
               rejects_token_if:   lambda { |token| token.size < 2 },
               substitutes_characters_with: CharacterSubstituters::WestEuropean.new

      # Note: Add more categories.
      #
      category :split,
               partial: Partial::None.new,
               tokenize: false,
               :from => :split_name_for_automatic_splitting
    end
    
    @splitter = Picky::Splitters::Automatic.new @splitting_index[:split]
  
  end
  
  def reindex
    @index.reindex
    @splitting_index.reindex
  end
  
end