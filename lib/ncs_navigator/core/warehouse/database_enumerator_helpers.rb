# -*- coding: utf-8 -*-


require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  module DatabaseEnumeratorHelpers
    ##
    # Extends {Database::DSL#produce_one_for_one} to support automatic
    # joins to replace association IDs with public IDs.
    def produce_one_for_one(table_name, mdes_model, options={})
      query = nil
      column_map = (options[:column_map] || {}).dup
      ignored_columns = (options[:ignored_columns] || []).dup

      selects = [options[:selects], 't.*'].flatten.compact
      joins = []

      if options[:public_ids]
        options[:public_ids].each_with_index do |pub, i|
          pub = case pub
                when String, Symbol
                  if pub.to_s == 'participants'
                    { :table => pub, :public_id => :p_id }
                  else
                    { :table => pub }
                  end
                else
                  pub
                end

          other_table = pub[:table].to_s
          # don't use String#singularize because AS/core_ext is not
          # loaded when this is executed.
          join_column = pub[:join_column] || pub[:public_ref] || other_table.sub(/s$/,'') + '_id'
          public_id_column = pub[:public_id] || join_column
          public_id_ref = pub[:public_ref] || public_id_column
          table_alias = "pub_#{i}"
          public_id_column_alias = "public_id_for_#{other_table}_as_#{join_column}"

          column_map[public_id_column_alias.to_sym] = public_id_ref.to_sym
          ignored_columns << join_column

          joins << "LEFT JOIN #{other_table} #{table_alias} ON t.#{join_column} = #{table_alias}.id"
          selects << "#{table_alias}.#{public_id_column} AS #{public_id_column_alias}"
        end
      end

      query = "SELECT #{selects.join(', ')}\nFROM #{table_name} t\n  #{joins.join("\n  ")}"
      if options[:where]
        query << "\nWHERE #{options[:where]}"
      end

      pr_opts = {
        :column_map => column_map,
        :ignored_columns => ignored_columns,
        :query => query
      }

      super(table_name, mdes_model, pr_opts)
    end

    ##
    # Method format datetime column in database to the desired MDES formatted
    # string representation (YYYY-MM-DDTHH:MM:SS).
    # Note that this is Postgres specific.
    # @return[String]
    def mdes_formatted_datetime_query(col)
      "(to_char(t.#{col}, 'YYYY-MM-DD') || 'T' || to_char(t.#{col} AT TIME ZONE 'UTC', 'HH24:MI:SS') ) as #{mdes_datetime_column_alias(col)}"
    end

    ##
    # Datetime column alias used in mdes_formatted_datetime_query and
    # in column_map for produce_one_for_one.
    # @return[String]
    def mdes_datetime_column_alias(col)
      "mdes_#{col}_value"
    end
  end
end