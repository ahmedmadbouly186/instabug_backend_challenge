# module Searchable
#   extend ActiveSupport::Concern

#   included do
#     include Elasticsearch::Model
#     include Elasticsearch::Model::Callbacks

#     mappings do
#       indexes :body, type: 'text', analyzer: 'standard', search_analyzer: 'standard'
#     end

#     def self.search(query)
#       params = {
#         query: {
#           match: {
#             body: {
#               query: query,
#               fuzziness: "AUTO"  # Optional: Allows for fuzzy matching.
#             }
#           }
#         }
#       }

#       self.__elasticsearch__.search(params).records.to_a
#     end
#   end
# end
