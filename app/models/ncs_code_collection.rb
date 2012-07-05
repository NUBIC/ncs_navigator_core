require 'forwardable'

class NcsCodeCollection
  extend Forwardable
  include Enumerable

  def_delegators :@query, :each, :where

  def initialize(query)
    @query = query
  end

  ##
  # Builds a (list_name, local_code) => NcsCode mapping from the given query.
  def table
    table = {}

    @query.each do |ncs_code|
      ln = ncs_code.list_name

      unless table.has_key?(ln)
        table[ln] = {}
      end

      table[ln][ncs_code.local_code] = ncs_code
    end

    table
  end
end
