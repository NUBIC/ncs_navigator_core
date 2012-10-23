module Field::Adapters
  module Person
    ATTRIBUTES = %w(
      first_name
      last_name
      middle_name
      person_id
      prefix_code
      suffix_code
    )

    class HashAdapter < Field::HashAdapter
      attr_accessors ATTRIBUTES
      attr_accessors %w(
        relationship_code
      )

      def model_class
        ::Person
      end
    end

    class ModelAdapter < Field::ModelAdapter
      attr_accessors ATTRIBUTES

      def person_public_id
        source.try(:person_id)
      end

      def participant_public_id
        source.try(:ancestors).try(:[], :participant).try(:p_id)
      end

      def relationship_code
        source.try(:relationship_code)
      end

      def pending_postrequisites
        return {} unless source

        { ::Person => [person_public_id],
          ::Participant => [participant_public_id]
        }
      end

      def ensure_postrequisites(map)
        return true unless source

        parameters = {
          :person_id => map.id_for(::Person, person_public_id),
          :participant_id => map.id_for(::Participant, participant_public_id),
          :relationship_code => relationship_code
        }

        if !ParticipantPersonLink.exists?(parameters)
          ParticipantPersonLink.create(parameters)
        else
          true
        end
      end
    end
  end
end
