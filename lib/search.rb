# TODO: Split this class into a client and a server part.
#
class Search
  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky

  # We don't use the normal range character.
  #
  Query::Token.range_character = '^'

  attr_reader :index, :interface, :splitter

  def self.instance
    @instance ||= new
  end

  def initialize
    # http://nlp.stanford.edu/IR-book/html/htmledition/dropping-common-terms-stop-words-1.html
    #
    # "it" is a prefix but we still stopword it.
    # We do not stop "on" as it is used for qualifying the platform.
    #
    words = %w(a an are as at be by for from) +
            %w(has he in is it its of that the) +
            %w(to was were will with)
    stopwords = /\b(#{words.join('|')})\b/i

    # Set up similarity configurations.
    #
    few_similars = Similarity::DoubleMetaphone.new 2

    # Set up partial configurations.
    #
    no_partial   = Partial::None.new
    full_partial = Partial::Substring.new(from: 1)

    default_indexing = {
      removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
      stopwords:          stopwords,
      splits_text_on:     /[\s\/\-\_\:\"\&\/]/,
      rejects_token_if:   lambda { |token| token.size < 2 },
    }

    # Define an index.
    #
    @index = Index.new :pods do
      id :id

      # We use the ids.
      #
      key_format :to_i

      # The default indexing. Override in category options.
      #
      indexing default_indexing

      # Note: Add more categories.
      #
      # category :id,
      #          partial: no_partial,
      #          qualifiers: [:id],
      #          :from => :indexed_id,
      #          :indexing => default_indexing.merge(
      #            removes_characters: false,
      #            splits_text_on: /\./
      #          )

      category :name,
               similarity: few_similars,
               partial: full_partial,
               qualifiers: [:name, :pod],
               from: :mapped_name,
               indexing: default_indexing.merge(
                 removes_characters: false,
                 splits_text_on:     /\s/,
               )
      category :author,
               similarity: few_similars,
               partial: full_partial,
               qualifiers: [:author, :authors, :written, :writer, :by],
               from: :mapped_authors,
               indexing: default_indexing.merge(
                 # Some names have funky characters. Let's normalize.
                 #
                 substitutes_characters_with:
                   CharacterSubstituters::WestEuropean.new,
               )
      category :version,
               partial: full_partial,
               from: :mapped_versions
      category :dependencies,
               partial: no_partial, # full_partial,
               qualifiers: [:dependency, :dependencies, :depends, :using, :uses, :use, :needs],
               from: :mapped_dependencies
      category :platform,
               partial: no_partial,
               qualifiers: [:platform, :on],
               from: :mapped_platform
      category :summary,
               partial: no_partial, # full_partial,
               from: :mapped_summary,
               indexing: default_indexing.merge(
                 removes_characters: /[^a-z0-9\s\-]/i # We remove special characters.
               )
      category :tags,
               partial: no_partial,
               qualifiers: [:tag, :tags],
               tokenize: false
    end

    # Define a search over the books index.
    #
    @interface = Search.new index do
      searching substitutes_characters_with:
                  CharacterSubstituters::WestEuropean.new,
                removes_characters: false,
                stopwords:          stopwords,
                splits_text_on:     /\s/,
                max_words: 4

      ignore :id

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

    @facets_interface = Search.new index do
      searching substitutes_characters_with:
                  # Normalizes special user input, Ä -> Ae, ñ -> n etc.
                  CharacterSubstituters::WestEuropean.new,
                removes_characters: false, # We don't remove characters.
                stopwords:          stopwords,
                splits_text_on:     /\s/,
                max_words: 4
    end

    @splitting_index = Index.new :splitting do
      # We use the ids.
      #
      key_format :to_i

      # We use the pod names as ids (as strings).
      #
      key_format :to_s

      # TODO: We need to work on this. This is still the Picky standard.
      #
      indexing default_indexing

      # Note: Add more categories.
      #
      category :split,
               partial: no_partial,
               tokenize: false,
               from: :split_name_for_automatic_splitting
    end

    @splitter = Picky::Splitters::Automatic.new @splitting_index[:split]

    @facet_keys = @index.categories.map(&:name).sort - [:id, :name, :author, :summary, :version, :dependencies]
  end

  # Reindex all pods.
  # Calls a block every n pods.
  #
  def reindex(every = 100, amount = nil)
    Pods.instance.each(amount).with_index do |pod, i|
      yield i if block_given? && (i % every == 0)
      replace pod
    end
  end

  def replace(pod)
    @index.replace pod
    @splitting_index.replace pod
  end

  def split(text)
    if CocoapodSearch.child
      Channel.instance(:search).call :split, text
    else
      @splitter.split text
    end
  end

  def index_facets(category_name)
    if CocoapodSearch.child
      Channel.instance(:search).call :index_facets, category_name
    else
      @index.facets category_name
    end
  end

  def search_facets(options = {})
    if CocoapodSearch.child
      Channel.instance(:search).call :search_facets, options
    else
      only   = options[:only]
      except = options[:except]
      also   = options[:include]

      keys = @facet_keys
      keys += [*also].map(&:to_sym)   if also
      keys &= [*only].map(&:to_sym)   if only
      keys -= [*except].map(&:to_sym) if except

      options[:counts] = options[:counts] != 'false'

      keys.inject({}) do |result, key|
        result[key] = @facets_interface.facets key, options
        result
      end
    end
  end

  def search(*args)
    if CocoapodSearch.child
      Channel.instance(:search).call :search, args
    else
      sorting = if args.last.respond_to?(:to_hash)
        filter_sort args.last.delete(:sort)
      end
      
      results = interface.search(*args)
      
      # Sort results.
      #
      results.sort_by &sorting if sorting
      
      results.to_hash
    end
  end

  def filter_sort(sort)
    sort_map[sort] || sort_map['name'] # Should be 'popularity'.
  end
  
  @@default_text_sort = ->(sort) do
    ->(id) { Pods.instance[id].send(sort) }
  end
  @@default_numeric_sort = ->(sort, desc) do
    desc = desc ? -1 : 1
    ->(id) { desc*Pods.instance[id].send(sort) }
  end
  def sort_map
    @sort_map ||= {
      'name'          => @@default_text_sort[:name],
      
      'popularity'    => @@default_numeric_sort[:popularity, false],
      '-popularity'   => @@default_numeric_sort[:popularity, true],
      
      'contributors'  => @@default_numeric_sort[:contributors, false],
      '-contributors' => @@default_numeric_sort[:contributors, true],
      'forks'         => @@default_numeric_sort[:forks, false],
      '-forks'        => @@default_numeric_sort[:forks, true],
      'stars'         => @@default_numeric_sort[:stargazers, false],
      '-stars'        => @@default_numeric_sort[:stargazers, true],
      'watchers'      => @@default_numeric_sort[:subscribers, false],
      '-watchers'     => @@default_numeric_sort[:subscribers, true],
    }
  end
end
