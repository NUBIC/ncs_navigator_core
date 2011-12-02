require 'ncs_navigator/mdes'

namespace :instruments do
  desc 'Lists all MDES elements in the surveys'
  task :report => :environment do
    Survey.most_recent_for_each_title.each do |survey|
      puts
      puts survey.title
      puts '=' * survey.title.size

      survey.mdes_table_map.each do |table_ident, t_contents|
        puts table_ident
        puts '-' * table_ident.size

        puts "Table: #{t_contents[:table]}"
        puts "Variables:"
        t_contents[:variables].each do |var_name, var_mapping|
          puts "  - #{var_name}"
          if var_mapping[:questions]
            case var_mapping[:questions].size
            when 1
              puts "    * maps to question #{var_mapping[:questions].first.reference_identifier}"
            else
              puts "    * maps to multiple questions:"
              var_mapping[:questions].each do |q|
                puts "      ! #{q.reference_identifier}"
              end
            end
          end
          if var_mapping[:fixed_value]
            puts "    * maps to fixed value #{var_mapping[:fixed_value].inspect}"
          end
        end
      end
    end
  end

  desc 'Cross-references the surveyor instruments with the MDES'
  task :analyze => :environment do
    mdes = NcsNavigatorCore.mdes
    Survey.most_recent_for_each_title.each do |survey|
      any_errors = false
      survey.mdes_table_map.each do |table_ident, t_contents|
        table_name = t_contents[:table]
        mdes_table = mdes[table_name]
        if mdes_table
          mdes_variable_names = mdes_table.variables.
            reject { |v| v.table_reference }.
            reject { |v| v.type.name =~ /primaryKey/ }.
            reject { |v| v.status == :retired }.
            collect(&:name) -
            %w(transaction_type psu_id recruit_type event_type event_repeat_key instrument_type instrument_version instrument_repeat_key)
          surv_variable_names = t_contents[:variables].keys

          mdes_not_surv = mdes_variable_names - surv_variable_names
          surv_not_mdes = surv_variable_names - mdes_variable_names
          surv_multiple_q =
            if ENV['IGNORE_MULTIPLE_Q']
              []
            else
              t_contents[:variables].
                select { |var_name, var_mapping| var_mapping[:questions] && var_mapping[:questions].size > 1 }.
                collect { |var_name, var_mapping| [var_name, var_mapping[:questions]] }
            end
          surv_multiple_on_primary =
            if mdes_table.primary_instrument_table?
              t_contents[:variables].select { |var_name, var_mapping| var_mapping[:questions] }.
                collect { |var_n, var_m| [var_n, var_m[:questions].select { |q| q.pick == 'any' }] }.
                reject { |var_n, qs| qs.empty? }
            else
              []
            end

          if mdes_not_surv.any? || surv_not_mdes.any? || surv_multiple_q.any? || surv_multiple_on_primary.any?
            unless any_errors
              actual_title = survey.title.split(' ').first
              puts
              puts '=' * actual_title.size
              puts actual_title
              puts '=' * actual_title.size
              any_errors = true
            end

            puts
            puts table_ident
            puts '-' * table_ident.size

            unless mdes_not_surv.empty?
              puts "  + In the MDES but not in any instrument:"
              mdes_not_surv.each do |var|
                puts "    - #{var}"
              end
            end
            unless surv_not_mdes.empty?
              puts "  * In the instrument but not in the MDES:"
              surv_not_mdes.each do |var|
                puts "    - #{var}"
              end
            end
            unless surv_multiple_q.empty?
              puts "  ^ Same MDES variable mapped to multiple questions:"
              len = surv_multiple_q.collect { |var, qs| var.size }.max
              surv_multiple_q.each do |var, qs|
                q_idents = qs.collect(&:reference_identifier).collect(&:inspect)
                puts "    - %-#{len}s mapped to #{q_idents.join(', ')}" % var
              end
            end
            unless surv_multiple_on_primary.empty?
              puts "  % Questions on the primary table which are pick=any:"
              surv_multiple_on_primary.each do |var, qs|
                q_idents = qs.collect(&:reference_identifier).collect(&:inspect)
                puts "    - #{var} (#{q_idents.join(', ')})"
              end
            end
          end
        else
          puts "There is no MDES table #{table_name}"
        end
      end
    end
  end

  task :mdes_tree => :environment do
    Survey.most_recent_for_each_title.each do |survey|
      actual_title = survey.title.split(' ').first
      puts
      puts actual_title

      tables = survey.mdes_table_map.
        collect { |ti, tc| tc[:table] }.uniq.
        collect { |t| NcsNavigatorCore.mdes[t] || fail("No MDES table #{t}") }

      parent_children = {}
      tables.each do |t|
        parent = t.instrument_table_tree[1]
        parent_children[parent] ||= []
        parent_children[parent] << t
      end

      dump_tree = lambda { |children, depth|
        (children || []).each do |child|
          puts ('  ' * depth) + child.name
          dump_tree[parent_children[child], depth + 1]
        end
      }

      dump_tree[parent_children[nil], 1]
    end
  end

  desc 'Lists the MDES tables that have no corresponding instrument'
  task :unmapped_tables => :environment do
    mapped_tables = Survey.most_recent_for_each_title.
      collect { |s| s.mdes_table_map.collect { |ti, tc| tc[:table] } }.
      flatten.uniq
    all_tables = NcsNavigatorCore.mdes.transmission_tables.
      select { |t| t.instrument_table? }.
      collect(&:name)

    (all_tables - mapped_tables).each do |table|
      puts table
    end
  end
end

class NcsNavigator::Mdes::TransmissionTable
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
