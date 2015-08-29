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

    # Set up partial configurations.
    #
    no_partial   = Partial::None.new
    full_partial = Partial::Substring.new(from: 1)

    default_indexing = {
      removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
      stopwords:          stopwords,
      splits_text_on:     %r{[\s/\-\_\:\"\&/]},
      rejects_token_if:   lambda { |token| token.size < 2 }
    }

    # Define an index.
    #
    @index = Index.new :pods do
      id :id
      
      # We never dump the index to file, so
      # let Picky optimize.
      #
      # When running GC.start in search worker:
      #   [BUG] object allocation during garbage collection phase
      #
      # Could be google_hash or https://bugs.ruby-lang.org/issues/10933.
      #
      #optimize :no_dump # google_hash caused some Ruby [BUG]s.
      
      # We use the ids.
      #
      key_format :to_i
      
      # We use Symbol keys.
      #
      symbol_keys true

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
      
      def boost(amount)
        Weights::Logarithmic.new(amount)
      end
      
      category :name,
               weight: boost(+2),
               # similarity: few_similars,
               partial: full_partial,
               qualifiers: [:name, :pod],
               from: :mapped_name,
               indexing: default_indexing.merge(
                 removes_characters: false,
                 splits_text_on:     /\s/,
               )
      category :author,
               # weight: boost(+0),
               # similarity: few_similars,
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
               # weight: boost(+0),
               partial: full_partial,
               from: :versions
      category :dependencies,
               weight: boost(-4),
               partial: full_partial,
               qualifiers: [:dependency, :dependencies, :depends, :using, :uses,
                            :use, :needs],
               from: :mapped_dependencies
      category :platform,
               # weight: boost(+0),
               partial: no_partial,
               qualifiers: [:platform, :on],
               from: :mapped_platform
      category :summary,
               weight: boost(-3),
               partial: no_partial, # full_partial,
               from: :mapped_summary,
               indexing: default_indexing.merge(
                 removes_characters: /[^a-z0-9\s\-]/i, # We remove special characters.
                 stems_with: Lingua::Stemmer.new
               )
      category :tags,
               weight: boost(+1),
               partial: no_partial,
               qualifiers: [:tag, :tags],
               tokenize: false
      category :subspecs,
               weight: boost(-6),
               partial: no_partial,
               qualifiers: %i(subspec subspecs),
               from: :mapped_subspec_names
      category :language,
               qualifiers: [:lang, :language],
               partial: no_partial,
               from: :mapped_language,
               tokenize: false
    end

    # Define a search over the books index.
    #
    @interface = Search.new index do
      # max_allocations 10
      
      searching substitutes_characters_with:
                  CharacterSubstituters::WestEuropean.new,
                removes_characters: false,
                stopwords:          stopwords,
                splits_text_on:     /[\s\/]/,
                max_words: 4

      ignore :id
    end

    @facets_interface = Search.new index do
      searching substitutes_characters_with:
                  # Normalizes special user input, Ä -> Ae, ñ -> n etc.
                  CharacterSubstituters::WestEuropean.new,
                removes_characters: false, # We don't remove characters.
                stopwords:          stopwords,
                splits_text_on:     /[\s\/]/,
                max_words: 4
    end

    @splitting_index = Index.new :splitting do
      # We use the ids.
      #
      key_format :to_s

      # We use Symbol keys.
      #
      symbol_keys true

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

    @facet_keys = @index.categories.map(&:name).sort - [:id, :name, :author,
                                                        :summary, :version,
                                                        :dependencies, :subspecs]
  end

  # Reindex all pods.
  # Calls a block every n pods.
  #
  def reindex_all(every = 100, amount = nil)
    Pods.instance.each(amount).with_index do |pod, i|
      yield i if block_given? && (i % every == 0)
      replace pod, Pods.instance
    end
  end
  
  # Try indexing a new pod.
  #
  def reindex(name)
    pod = Pod.all { |pods| pods.where(name: name) }.first
    replace pod, Pods.instance
    pod.release_indexing_memory
    $stdout.print ?✓
  rescue PG::UnableToSend
    $stdout.puts 'PG::UnableToSend raised! Reconnecting to database.'
    load 'lib/database.rb'
    retry
  rescue StandardError => e
    # Catch any error and reraise as a "could not run" error.
    #
    $stderr.puts "[Warning] Reindexing #{name} in INDEX PROCESS has failed: #{e.message}"
  end

  def replace(pod, pods) # TODO: Redesign.
    pods[pod.id] = pod
    # "Adding" pods to the index will not replace index data that
    # is already in there (but add new index data).
    @index.add pod
    @splitting_index.add pod
    # pod.reduce_memory_usage # TODO ?
  end

  def remove(pod)
    @index.remove pod
    @splitting_index.remove pod
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
  
  def picky_search(query, amount, offset, options = {})
    if CocoapodSearch.child
      Channel.instance(:search).call :picky_search, [query, amount, offset, options]
    else
      sorting = filter_sort options.delete(:sort)
      format = options.delete(:format)
      rendering = options.delete(:rendering)
      
      tokens = interface.tokenized query
      
      # Max amount is 100.
      amount = amount.to_i
      if amount > 100
        amount = 100
      end
      
      # TODO Timeout here.
      results = interface.search_with tokens, amount, offset.to_i, query, options[:unique]
      
      # Sort results.
      #
      results.sort_by(&sorting) if sorting
      
      # Promote exact result to top of allocation if it's a single word.
      #
      if tokens.size == 1
        text = tokens.first.text
        if text
          text = text.downcase
          found = false
          
          # TODO We don't need to look through all allocations,
          # only those with combinations "name". 
          #
          results.allocations.each do |allocation|
            ids = allocation.ids
            # next if ids.size == 1
            
            pods = Pods.instance
            
            # Find the first exact hit and promote it.
            # Note: slows the search engine down considerably.
            #
            # TODO This currently only finds the pod if it's in the first 20 results.
            #
            if found = ids.find { |id| pods[id].name.downcase == text }
              ids.delete found
              ids.unshift found
              break
            end
          end
        end
      end
      
      if block_given?
        yield results, format, rendering
      else
        results.to_hash
      end
    end
  end

  def search(*args)
    if CocoapodSearch.child
      Channel.instance(:search).call :search, args
    else
      indexing_progress = args.pop
      picky_search(*args) do |results, format, rendering|
        # Render.
        #
        render_block = case rendering
          when :hash
            ->(item) { item.to_h }
          when :ids
            ->(item) { item.name }
          end
        case format
          when :flat
            results = Pods.instance.for(results.ids).map(&render_block)
          when :picky
            results = results.to_hash
            results.extend Picky::Convenience
            results.amend_ids_with Pods.instance.for(results.ids).map(&render_block)
            results.clear_ids
            results[:indexing_progress] = indexing_progress
            results
        end
        results
      end
    end
  end

  def filter_sort(sort)
    sort_map[sort] || sort_map['popularity'] # Default is popularity.
  end

  @@default_text_sort = ->(sort) do
    ->(id) { Pods.instance[id].send(sort) }
  end

  @@default_numeric_sort = ->(sort, desc) do
    desc = desc ? -1 : 1
    ->(id) { desc * Pods.instance[id].send(sort) }
  end

  def sort_map
    @sort_map ||= {
      'name'          => @@default_text_sort[:name],

      'popularity'    => @@default_numeric_sort[:popularity, true],
      '-popularity'   => @@default_numeric_sort[:popularity, false],
      'quality'       => @@default_numeric_sort[:quality, true],
      '-quality'      => @@default_numeric_sort[:quality, false],

      'contributors'  => @@default_numeric_sort[:contributors, true],
      '-contributors' => @@default_numeric_sort[:contributors, false],
      'forks'         => @@default_numeric_sort[:forks, true],
      '-forks'        => @@default_numeric_sort[:forks, false],
      'stars'         => @@default_numeric_sort[:stargazers, true],
      '-stars'        => @@default_numeric_sort[:stargazers, false],
      'watchers'      => @@default_numeric_sort[:subscribers, true],
      '-watchers'     => @@default_numeric_sort[:subscribers, false],
    }
  end
end
