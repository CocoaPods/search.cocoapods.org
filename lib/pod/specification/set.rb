module Pod
  class Specification

    # Extend the pod sets with an id method.
    #
    class Set

      def id
        name
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
        specification.platform || [:ios, :osx]
      end

      def mapped_summary
        specification.summary
      end

    end

  end
end