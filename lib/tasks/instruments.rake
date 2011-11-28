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
    all_mdes_map = {}
    Survey.all.each do |survey|
      survey.mdes_table_map.values.each do |t_contents|
        all_mdes_map[t_contents[:table]] ||= []
        all_mdes_map[t_contents[:table]] << t_contents[:variables]
      end
    end

    # TODO: centrally specify the current MDES version
    mdes = NcsNavigator::Mdes('2.0')
    all_mdes_map.keys.sort.each do |table_name|
      variable_loh = all_mdes_map[table_name]
      mdes_table = mdes[table_name]
      if mdes_table
        mdes_variable_names = mdes_table.variables.
          reject { |v| v.table_reference }.
          reject { |v| v.type.name =~ /primaryKey/ }.
          collect(&:name) - %w(transaction_type psu_id recruit_type event_type event_repeat_key instrument_type instrument_version instrument_repeat_key)
        surv_variable_names = variable_loh.collect { |var_h| var_h.keys }.flatten.uniq

        mdes_not_surv = mdes_variable_names - surv_variable_names
        surv_not_mdes = surv_variable_names - mdes_variable_names

        unless mdes_not_surv.empty? && surv_not_mdes.empty?
          titles = variable_loh.collect { |var_h| var_h.values }.
            collect { |var_maps|
              var_maps.collect { |var_map|
                (var_map[:questions] || []).collect { |q| q.survey_section.survey.title.split(/ /).first }
              }
            }.flatten.uniq

          puts
          puts "#{table_name} (ref'd in #{titles.join(', ')})"
          puts '-' * table_name.size
          unless mdes_not_surv.empty?
            puts "  + In the MDES but not in any instrument:"
            mdes_not_surv.each do |var|
              puts "    - #{var}"
            end
          end
          unless surv_not_mdes.empty?
            puts "  * In some instrument but not in the MDES:"
            len = surv_not_mdes.collect(&:size).max
            surv_not_mdes.each do |var|
              titles = variable_loh.collect { |var_h| var_h[var] }.
                compact.
                collect { |var_map|
                  var_map[:questions].collect { |q| q.survey_section.survey.title.split(/ /).first }
                }.flatten.uniq
              puts "    - %-#{len}s (in #{titles.join(', ')})" % var
            end
          end
        end
      else
        puts "There is no table #{table_name} in the MDES."
      end
    end
  end
end
