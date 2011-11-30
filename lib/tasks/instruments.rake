require 'ncs_navigator/mdes'

namespace :instruments do
  desc 'Lists all MDES elements in the surveys'
  task :report => :environment do
    Survey.all.each do |survey|
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
    # TODO: centrally specify the current MDES version
    mdes = NcsNavigator::Mdes('2.0')
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
          surv_multiple_q = t_contents[:variables].
            select { |var_name, var_mapping| var_mapping[:questions] && var_mapping[:questions].size > 1 }.
            collect { |var_name, var_mapping| [var_name, var_mapping[:questions]] }

          if mdes_not_surv.any? || surv_not_mdes.any? || surv_multiple_q.any?
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
          end
        else
          puts "There is no MDES table #{table_name}"
        end
      end
    end
  end
end
