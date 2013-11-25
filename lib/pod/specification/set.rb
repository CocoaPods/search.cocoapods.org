module Pod
  class Specification

    # This class preprocesses the pod specs
    # for indexing in Picky and also handles spec errors.
    #
    # Note: Very explicitly handles errors.
    #
    class Set

      # Extend the pod sets with an id method.
      #
      def id
        name
      end

      # Returns not just the name, but also:
      #  * Separated uppercase/lowercase parts.
      #  * Name without initials.
      #
      def split_name
        [
          name,
          name.split(/([A-Z]?[a-z]+)/).map(&:downcase),
          (name[2..-1] if name.match(/\A[A-Z]{3}[a-z]/))
        ].compact.flatten
      end

      def mapped_name
        split_name.join ' '
      end

      def mapped_authors
        spec_authors = specification.authors
        spec_authors && spec_authors.keys.join(' ') || ''
      rescue Pod::Informative, StandardError, SyntaxError
        ''
      end

      def mapped_versions
        versions.reduce([]) { |combined, version| combined << version.version }.join ' '
      rescue Pod::Informative, StandardError, SyntaxError
        ''
      end

      def mapped_dependencies
        specification.dependencies.map(&:name).join ' '
      rescue Pod::Informative, StandardError, SyntaxError
        ''
      end

      def mapped_platform
        specification.available_platforms.map(&:name).sort.join(' ')
      rescue Pod::Informative, StandardError, SyntaxError
        '' # i.e. never found.
      end

      # Summary with words already contained in
      # name removed such as to minimize
      # multiple results.
      #
      def mapped_summary
        specification.summary[0..139]
      rescue Pod::Informative, StandardError, SyntaxError
        ''
      end
      
      # Tag extracted from summary.
      #
      # Note: Just mocking the NLP functionality.
      #
      @@tags = %w{
        analytics
        api
        authentication
        communication
        gesture
        http
        json
        logging
        network
        notification
        parser
        password
        payment
        rest
        serialization
        test
        widget
        xml
      }
      def tags
        specification.summary.downcase.scan(/\b(#{@@tags.join('|')})\w*\b/).flatten.uniq
      rescue Pod::Informative, StandardError, SyntaxError
        []
      end

    end

  end
end
