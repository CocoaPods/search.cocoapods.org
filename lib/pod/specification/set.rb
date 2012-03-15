module Pod
  class Specification
    
    # This class preprocesses the pod specs
    # for indexing in Picky and also handles spec errors.
    #
    # Note: Very explicitly handles errors.
    # TODO Handle more elegantly.
    #
    class Set
      
      # Extend the pod sets with an id method.
      #
      def id
        name
      end
      
      # Returns not just the name, but the
      # Uppercase/lowercase parts.
      #
      def split_name
        [name, name.split(/([A-Z]?[a-z]+)/).map(&:downcase)].flatten
      end
      
      def mapped_name
        split_name.join ' '
      end

      def mapped_authors
        spec_authors = specification.authors
        spec_authors && spec_authors.keys.join(' ') || ''
      rescue StandardError
        ''
      end

      def mapped_versions
        versions.reduce([]) { |combined, version| combined << version.version }.join ' '
      rescue StandardError
        ''
      end

      def mapped_dependencies
        specification.dependencies.map(&:name).join ' '
      rescue StandardError
        ''
      end

      def mapped_platform
        specification.platform.name || "ios osx"
      rescue StandardError
        '' # i.e. never found.
      end
      
      # Summary with words already contained in
      # name removed such as to minimize
      # multiple results.
      #
      def mapped_summary
        specification.summary
      rescue StandardError
        ''
      end
      
    end

  end
end