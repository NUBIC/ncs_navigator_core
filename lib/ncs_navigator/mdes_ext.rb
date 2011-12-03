require 'ncs_navigator/mdes'

module NcsNavigator::Mdes
  class TransmissionTable
    ##
    # A list starting with this table and tracing back to its primary
    # instrument table. If this table is not an instrument table,
    # returns nil.
    def instrument_table_tree
      @instrument_table_tree ||=
        if primary_instrument_table?
          [self]
        elsif operational_table?
          nil
        else
          [self] + variables.collect { |v| v.table_reference }.compact.
            collect { |t| t.instrument_table_tree }.compact.
            sort_by { |parents| parents.size }.first
        end
    end
  end
end
