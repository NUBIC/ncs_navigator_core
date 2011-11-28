require 'ncs_navigator/core'

module NcsNavigator::Core
  module MdesInstrumentSurvey
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

    def update_mdes_table_map(map, q, table_identifier, variable_name)
      map[table_identifier] ||= {}
      map[table_identifier].tap do |table|
        table_name, fixed = parse_mdes_table_identifier(table_identifier)
        table[:table] = table_name
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

    def all_questions
      sections.collect(&:questions).flatten
    end
    private :all_questions
  end
end

