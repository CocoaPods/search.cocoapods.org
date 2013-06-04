class Search
    
  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky

  attr_reader :index, :interface

  def initialize pods
    @pods = pods
  
    # Define an index.
    #
    @index = Index.new :pods do

      # Use the cocoapods-specs repo for the data.
      #
      source { pods.sets }

      # As a test, we use the pod names as ids
      # (symbols to enhance performance).
      #
      key_format :to_sym

      # TODO We need to work on this. This is still the Picky standard.
      #
      indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
               stopwords:          /\b(and|the|of|it|in|for)\b/i,
               splits_text_on:     /[\s\/\-\_\:\"\&\/]/,
               rejects_token_if:   lambda { |token| token.size < 2 }

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
  
    # Define a search over the books index.
    #
    @interface = Search.new index do
      searching substitutes_characters_with: CharacterSubstituters::WestEuropean.new, # Normalizes special user input, Ä -> Ae, ñ -> n etc.
                removes_characters: /[^a-z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
                stopwords:          /\b(and|the|of|it|in|for)\b/i,
                splits_text_on:     /[\s\/\-\&]+/

      boost [:name, :author]  => +3,
            [:name]           => +2,
            [:name, :summary] => -3, # Summary is the least important.
            [:summary]        => -3, #
            [:platform, :name, :author]  => +3,
            [:platform, :name]           => +2,
            [:platform, :name, :summary] => -3, # Summary is the least important.
            [:platform, :summary]        => -3  #
    end
  
  end
  
end