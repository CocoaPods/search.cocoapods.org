# module Pod
#
#   class Specification
#
#     # This class preprocesses the pod specs
#     # for indexing in Picky and also handles spec errors.
#     #
#     # Note: Very explicitly handles errors.
#     #
#     class WrappedSet
#
#       attr_reader :set
#
#       def initialize set
#         @set = set
#       end
#
#       # Extend the pod sets with an id method.
#       #
#       def id
#         name
#       end
#
#       def name
#         set.name
#       end
#
#       def versions
#         set.versions
#       end
#
#       # Caches the specification.
#       #
#       def specification
#         @specification ||= set.specification
#       end
#
#       # Returns not just the name, but also:
#       #  * Separated uppercase/lowercase parts.
#       #  * Name without initials.
#       #
#       def split_name
#         first, *rest = name.split(/\b/)
#         initials, after_initials = first.split(/(?=[A-Z][a-z])/, 2)
#         [
#           name,
#           initials,
#           after_initials,
#           first,
#           *rest,
#           *name.split(/([A-Z]?[a-z]+)/)
#         ].compact.map(&:downcase).uniq.map(&:freeze)
#       end
#
#       # This is to provide helpful suggestions on long words.
#       #
#       def split_name_for_automatic_splitting
#         temp = name
#         if temp
#           if temp.match /\A[A-Z]{3}[a-z]/
#             temp = temp[2..-1]
#           end
#           (temp && temp.split(/([A-Z]?[a-z]+)/).map(&:downcase) || []).reject do |part|
#             part.size < 3
#           end
#         else
#           []
#         end
#       end
#
#       def mapped_name
#         split_name.join ' '
#       end
#
#       def mapped_authors
#         spec_authors = specification.authors
#         spec_authors && spec_authors.keys.join(' ') || ''
#       rescue Pod::Informative, StandardError, SyntaxError
#         ''
#       end
#
#       def mapped_versions
#         versions.reduce([]) { |combined, version| combined << version.version }.join ' '
#       rescue Pod::Informative, StandardError, SyntaxError
#         ''
#       end
#
#       def mapped_dependencies
#         specification.dependencies.map(&:name).join ' '
#       rescue Pod::Informative, StandardError, SyntaxError
#         ''
#       end
#
#       def mapped_platform
#         specification.available_platforms.map(&:name).sort.join(' ')
#       rescue Pod::Informative, StandardError, SyntaxError
#         '' # i.e. never found.
#       end
#
#       # Summary with words already contained in
#       # name removed such as to minimize
#       # multiple results.
#       #
#       def mapped_summary
#         specification.summary[0..139]
#       rescue Pod::Informative, StandardError, SyntaxError
#         ''
#       end
#
#       # Tag extracted from summary.
#       #
#       # Note: http://search.cocoapods.org/api/v1/pods.facets.json?include=name&only=name&at-least=30
#       #
#       @@tags = %w{
#         alert
#         analytics
#         api
#         authentication
#         button
#         client
#         communication
#         controller
#         gesture
#         http
#         image
#         json
#         kit
#         layout
#         logging
#         manager
#         navigation
#         network
#         notification
#         parser
#         password
#         payment
#         picker
#         progress
#         rest
#         serialization
#         table
#         test
#         text
#         view
#         widget
#         xml
#       }
#       def tags
#         specification.summary.downcase.scan(/\b(#{@@tags.join('|')})\w*\b/).flatten.uniq
#       rescue Pod::Informative, StandardError, SyntaxError
#         []
#       end
#
#     end
#
#   end
# end
