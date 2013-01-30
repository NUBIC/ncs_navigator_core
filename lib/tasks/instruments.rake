require 'ncs_navigator/mdes'

namespace :instruments do
  desc 'Lists all MDES elements in the surveys'
  task :report => :environment do
    Survey.most_recent.order(:title).each do |survey|
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
    Survey.most_recent.order(:title).each do |survey|
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
          surv_no_other = survey.mdes_other_pairs.select { |pair|
            t_contents[:variables].collect { |vn, vm| vm[:questions] }.compact.flatten.include?(pair[:coded])
          }.reject { |pair| pair[:other] || pair[:parent_other] }.collect { |pair|
            t_contents[:variables].find { |vn, vm| vm[:questions] && vm[:questions].include?(pair[:coded]) }
          }.collect { |var_name, var_mapping| var_name }

          if mdes_not_surv.any? || surv_not_mdes.any? || surv_multiple_q.any? || surv_multiple_on_primary.any? || surv_no_other.any?
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
            unless surv_no_other.empty?
              puts "  & Multivalued questions with an other option but no other question:"
              surv_no_other.each do |var|
                puts "    - #{var}"
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
    Survey.most_recent.order(:title).each do |survey|
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
    Survey.mdes_unused_instrument_tables.each do |table|
      puts table
    end
  end

  desc 'List all prepopulated questions are not known to ResponseSetPrepopulators'
  task :check_prepopulation => :environment do
    # Gather all questions that are marked 'prepopulated'
    prepopulated_question_ids = []
    prepopulated_question_ids_for_surveys = {}
    Survey.most_recent.order(:title).each do |survey|
      survey.sections_with_questions.each do |section|
        section.questions.each do |q|
          prepopulated_question_ids_for_surveys[q.reference_identifier] = survey.title if q.reference_identifier.to_s.include? "prepopulated"
        end
      end
    end
    prepopulated_question_ids = prepopulated_question_ids_for_surveys.keys.uniq

    puts "# of questions that are marked 'prepopulated' = #{prepopulated_question_ids.size}"

    # get questions known to ResponseSetPrepopulators
    known_prepopulated_question_ids = []
    NcsNavigator::Core::ResponseSetPopulator::Base.subclasses.each do |sc|
      known_prepopulated_question_ids << sc.new(Person.new, Instrument.new, Survey.new).reference_identifiers
    end
    known_prepopulated_question_ids = known_prepopulated_question_ids.flatten.uniq

    puts "# of 'prepopulated' questions known to ResponseSetPrepopulators = #{known_prepopulated_question_ids.size}"

    # which prepopulated questions are not handled by the ResponseSetPrepopulators
    difference = prepopulated_question_ids - known_prepopulated_question_ids

    # output the unhandled questions and in which surveys they are
    difference.each_with_index do |unhandled, i|
      puts "#{i + 1}) #{prepopulated_question_ids_for_surveys[unhandled]}\n    - #{unhandled}"
    end
  end

  desc 'List all Survey titles that do not have a matching PSC instrument label (and the other way too)'
  task :check_psc_labels_match_survey_titles => :environment do

    msg = "
*****
This only checks the current PSC template against your local database for the known Surveys.
Make sure that you have loaded all Surveys locally.
e.g. bundle exec rake setup:surveys
*****"
    puts msg

    require 'rexml/document'
    include REXML

    xmlfile = File.new("#{Rails.root}/spec/fixtures/psc/current_hilo_template_snapshot.xml")
    xmldoc = Document.new(xmlfile)

    # Collect all instrument labels
    raw_labels = []
    XPath.each(xmldoc, "//label") do |l|
      name = l.attributes["name"]
      raw_labels << name if name.include? "instrument"
    end
    instrument_labels = {}
    raw_labels.uniq!.each do |i|
      normalized_label = Survey.to_normalized_string(i.split(':').last)
      instrument_labels[normalized_label] = i
    end

    # Collect all known survey titles
    raw_titles = Survey.select("title").all.map(&:title)
    survey_titles = {}
    raw_titles.uniq!.each do |t|
      survey_titles[Survey.to_normalized_string(t)] = t
    end

    puts "\nKnown Survey Titles that do not have an Instrument label in PSC:\n"

    (survey_titles.keys - instrument_labels.keys).sort.each_with_index do |survey_without_label, idx|
      puts "#{idx+1}). #{survey_without_label}: #{survey_titles[survey_without_label]}"
    end

    puts "\nInstrument Labels in PSC that do not match a Survey:\n"

    (instrument_labels.keys - survey_titles.keys).sort.each_with_index do |dangling_label, idx|
      puts "#{idx+1}). #{dangling_label}: #{instrument_labels[dangling_label]}"
    end

  end
end
