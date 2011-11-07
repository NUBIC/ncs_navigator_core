module NcsNavigator::Warehouse::Transformers
  module NavigatorCoreHelpers
    ##
    # Wrapper for {Database::DSL#produce_records} that automatically
    # invokes `model_row` assuming that each source row results in
    # exactly one MDES row. It also does automatic joins to replace
    # association IDs with public IDs.
    def produce_one_for_one(table_name, mdes_model, options={})
      query = nil
      column_map = (options[:column_map] || {}).dup
      ignored_columns = (options[:ignored_columns] || []).dup
      if options[:public_ids]
        joins = []
        selects = ['t.*']
        options[:public_ids].each_with_index do |pub, i|
          pub = case pub
                when String
                  if pub.to_s == 'participants'
                    { :table => pub, :public_id => :p_id }
                  else
                    { :table => pub }
                  end
                else
                  pub
                end

          other_table = pub[:table]
          join_column = other_table.to_s.singularize + '_id'
          public_id_column = pub[:public_id] || join_column
          table_alias = "pub_#{i}"
          public_id_column_alias = "public_#{public_id_column}"

          column_map[public_id_column_alias.to_sym] = public_id_column.to_sym
          ignored_columns << join_column

          joins << "LEFT JOIN #{other_table} #{table_alias} ON t.#{join_column} = #{table_alias}.id"
          selects << "#{table_alias}.#{public_id_column} AS #{public_id_column_alias}"
        end

        query = "SELECT #{selects.join(',')}\nFROM #{table_name} t\n  #{joins.join("\n  ")}"
      end

      pr_opts = {}
      if query
        pr_opts[:query] = query
      end

      produce_records(table_name, :query => query) do |row|
        model_row(mdes_model, row, :column_map => column_map, :ignored_columns => ignored_columns)
      end
    end
  end
end
