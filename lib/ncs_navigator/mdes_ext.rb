# -*- coding: utf-8 -*-

require 'ncs_navigator/mdes'

module NcsNavigator::Mdes
  class DispositionCode
    include ActiveModel::Serialization

    def self.last_modified
      fn = NcsNavigatorCore.configuration.mdes.source_documents.disposition_codes

      File.stat(fn).mtime if File.exist?(fn)
    end

    def attributes
      ATTRIBUTES.each_with_object({}) { |attr, h| h[attr] = send(attr) }
    end

    def read_attribute_for_serialization(attr)
      send(attr)
    end
  end

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

  class Specification
    def disposition_for(category_code, interim_code)
      disposition_codes.detect do |dc|
        dc.category_code == category_code && dc.interim_code.to_i == interim_code
      end
    end
  end
end
