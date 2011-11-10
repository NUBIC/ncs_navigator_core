require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  module EnumeratorHelpers
    ##
    # Extends {Database::DSL#produce_one_for_one} to support automatic
    # joins to replace association IDs with public IDs.
    def produce_one_for_one(table_name, mdes_model, options={})
      query = nil
      column_map = (options[:column_map] || {}).dup
      ignored_columns = (options[:ignored_columns] || []).dup
      if options[:public_ids]
        joins = []
        selects = ['t.*']
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
          join_column = pub[:join_column] || pub[:public_ref] || other_table.singularize + '_id'
          public_id_column = pub[:public_id] || join_column
          public_id_ref = pub[:public_ref] || public_id_column
          table_alias = "pub_#{i}"
          public_id_column_alias = "public_#{public_id_column}"

          column_map[public_id_column_alias.to_sym] = public_id_ref.to_sym
          ignored_columns << join_column

          joins << "LEFT JOIN #{other_table} #{table_alias} ON t.#{join_column} = #{table_alias}.id"
          selects << "#{table_alias}.#{public_id_column} AS #{public_id_column_alias}"
        end

        query = "SELECT #{selects.join(', ')}\nFROM #{table_name} t\n  #{joins.join("\n  ")}"
      end

      pr_opts = {
        :column_map => column_map,
        :ignored_columns => ignored_columns
      }
      pr_opts[:query] = query if query

      super(table_name, mdes_model, pr_opts)
    end
  end
end
