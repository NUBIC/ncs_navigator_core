require 'ncs_navigator/core'

module NcsNavigator::Core::Fieldwork
  ##
  # Groups responses by question ID.
  #
  # Mix this into a {Superposition} instance or anything with a compatible
  # entity map.
  module ResponseGrouping
    def group_responses
      self.response_groups = {}.tap do |h|
        responses.each do |_, states|
          states.each do |state, response|
            qid = response.question_id

            unless h.has_key?(qid)
              h[qid] = {}
            end

            unless h[qid].has_key?(state)
              h[qid][state] = []
            end

            h[qid][state] << response
          end
        end
      end
    end
  end
end
