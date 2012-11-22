require 'forwardable'

class NcsCodeCollection
  extend Forwardable
  include Enumerable

  def_delegators :@query, :each, :where

  def initialize(query)
    @query = query
  end

  ##
  # Builds a (list_name, key) => NcsCode mapping from the given query.
  def table(key = :local_code)
    table = {}

    @query.each do |ncs_code|
      ln = ncs_code.list_name

      unless table.has_key?(ln)
        table[ln] = {}
      end

      table[ln][ncs_code.send(key)] = ncs_code
    end

    table
  end
end
