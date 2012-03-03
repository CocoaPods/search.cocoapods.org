module Pod
  class Specification

    # Extend the pod sets with an id method.
    #
    class Set

      def id
        name
      end
      
      # Returns not just the name, but the
      # Uppercase/lowercase parts with
      # length > 1.
      #
      def split_name
        [name, name.split(/([A-Z]?[a-z]+)/).map(&:downcase).select { |word| word.size > 1 }].flatten
      end
      
      def mapped_name
        split_name.join ' '
      end

      def mapped_authors
        spec_authors = specification.authors
        spec_authors && spec_authors.keys.join(' ') || ''
      end

      def mapped_versions
        versions.reduce([]) { |combined, version| combined << version.version }.join ' '
      end

      def mapped_dependencies
        specification.dependencies.map(&:name).join ' '
      end

      def mapped_platform
        specification.platform.name || "ios osx"
      end
      
      # Summary with words already contained in
      # name removed such as to minimize
      # multiple results.
      #
      def mapped_summary
        specification.summary
      end

    end

  end
end