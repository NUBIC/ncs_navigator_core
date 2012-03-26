require 'ncs_navigator/core'

module NcsNavigator::Core
  module MdesInstrumentSurvey
    extend ActiveSupport::Concern

    module ClassMethods
      def mdes_instrument_tables
        mdes_surveys_by_mdes_table.keys
      end

      def mdes_primary_instrument_tables
        @mdes_primary_instrument_tables ||= mdes_instrument_tables.select { |name|
          NcsNavigatorCore.mdes[name].primary_instrument_table?
        }
      end

      def mdes_unused_instrument_tables
        NcsNavigatorCore.mdes.transmission_tables.
          select { |t| t.instrument_table? }.collect(&:name) - mdes_instrument_tables
      end

      def mdes_surveys_by_mdes_table
        @mdes_surveys_by_mdes_table ||= most_recent_for_each_title.inject({}) do |h, survey|
          survey.mdes_table_map.collect { |ti, tc| tc[:table] }.flatten.each do |table|
            h[table] = survey
          end
          h
        end
      end

      def mdes_reset!
        @mdes_primary_instrument_tables = nil
        @mdes_surveys_by_mdes_table = nil
      end
    end

    ##
    # Extracts the mapping to the MDES that is embedded in this
    # {Survey}'s data export identifiers.
    #
    # @return Hash[String, Hash<Symbol, Object>]
    def mdes_table_map(options={})
      @mdes_table_map ||= all_questions.inject({}) do |h, q|
        de_id_parts = q.data_export_identifier.split('.')
        if de_id_parts.size != 2
          h
        else
          update_mdes_table_map(h, q, de_id_parts[0].downcase, de_id_parts[1].downcase)
        end
      end
    end

    ##
    # @return [Array<String>] a three-element array containing the names
    #   of the MDES table and MDES variable to which the given
    #   question maps (if any), plus the fixed value mapping for that table.
    def mdes_mapping_for_question(q)
      mdes_table_map.collect { |ti, tc|
        [
          tc[:table],
          tc[:variables].find { |vn, vm|
            (vm[:questions] || []).include?(q)
          }.try(:first),
          tc[:variables].collect { |vn, vm| [vn, vm[:fixed_value]] }.
            select { |vn, fixed| fixed }.inject({}) { |h, (vn, fixed)| h[vn] = fixed; h }
        ]
      }.find { |table_name, var_name| var_name }
    end

    def update_mdes_table_map(map, q, table_identifier, variable_name)
      map[table_identifier] ||= {}
      map[table_identifier].tap do |table|
        table_name, fixed = parse_mdes_table_identifier(table_identifier)
        table[:table] = table_name
        table[:primary] = NcsNavigatorCore.mdes[table_name].primary_instrument_table?
        table[:variables] ||= {}

        fixed.each do |fixed_var, fixed_val|
          table[:variables][fixed_var] ||= {}
          table[:variables][fixed_var][:fixed_value] = fixed_val
        end

        table[:variables][variable_name] ||= { }
        table[:variables][variable_name][:questions] ||= []
        table[:variables][variable_name][:questions] << q
      end
      map
    end
    private :update_mdes_table_map

    def parse_mdes_table_identifier(identifier)
      if identifier =~ %r{^(.*?)\[(.*?)\]$}
        table_name = $1
        fixed = Hash[*$2.split('=')]
      else
        table_name = identifier
        fixed = {}
      end
      [table_name, fixed]
    end
    private :parse_mdes_table_identifier

    ##
    # Heuristically matches any multivalued questions with an other
    # (code=-5) option to the associated "other" question.
    #
    # @return [Array<Hash<[:coded,:other], [Question,nil]>>] a list of
    #   pairs of questions.
    def mdes_other_pairs
      @mdes_other_pairs ||= all_questions.select { |q|
        q.pick == 'any' && q.answers.select { |a| a.response_class == 'answer' }.
          collect(&:reference_identifier).include?('neg_5')
      }.collect do |coded|
        {
          :coded => coded,
        }.merge(find_other_question(coded) || {})
      end
    end

    # @private
    MDES_OTHER_OVERRIDES = {
      'PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH_2' =>
        'PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH2_OTH'
    }

    def find_other_question(coded_question)
      in_same_table = all_questions.find { |q|
        if MDES_OTHER_OVERRIDES[coded_question.data_export_identifier]
          q.data_export_identifier == MDES_OTHER_OVERRIDES[coded_question.data_export_identifier]
        else
          q.data_export_identifier == coded_question.data_export_identifier + '_OTH'
        end
      }
      return { :other => in_same_table } if in_same_table

      coded_table_name, coded_variable_name, coded_fixed = mdes_mapping_for_question(coded_question)
      mdes_table = NcsNavigatorCore.mdes[coded_table_name]
      mdes_parent = mdes_table.instrument_table_tree[1]
      if mdes_parent
        # TODO: might change the way fixed works for associated
        # tables, which would make this more complicated.
        parent_table_contents = mdes_table_map.find { |ti, tc|
          tc_fixed = tc[:variables].collect { |vn, vm| [vn, vm[:fixed_value]] }.
            select { |vn, fixed| fixed }.inject({}) { |h, (vn, fixed)| h[vn] = fixed; h }
          tc[:table] == mdes_parent.name && tc_fixed == coded_fixed
        }
        if parent_table_contents
          parent_other = parent_table_contents.last[:variables].
            find { |var_name, var_mapping| var_name == "#{coded_variable_name}_oth" }.
            try(:last).try(:[], :questions).try(:first)
          return { :parent_other => parent_other } if parent_other
        end
      end
    end
    private :find_other_question

    def all_questions
      sections_with_questions.collect(&:questions).flatten
    end
    private :all_questions
  end
end
