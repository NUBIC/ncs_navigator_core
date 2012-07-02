

require 'ncs_navigator/core'

require 'forwardable'

module NcsNavigator::Core::Warehouse
  class InstrumentImporter
    extend Forwardable

    BLOCK_SIZE = 2500

    def_delegators :@wh_config, :log

    def initialize(wh_config)
      @wh_config = wh_config
      @progress = ProgressTracker.new(wh_config)
    end

    def import
      PaperTrail.whodunnit = 'instrument_importer'
      begin
        @progress.start
        Survey.mdes_primary_instrument_tables.each do |primary|
          create_or_update_response_sets_for_model(
            @wh_config.models_module.mdes_order.detect { |model| model.mdes_table_name == primary })
        end
        @progress.complete
      ensure
        PaperTrail.whodunnit = nil
      end
    end

    private

    def create_or_update_response_sets_for_model(model)
      count = model.count
      log.info "Updating or creating response sets for #{count} records from #{model}"
      offset = 0
      while offset < count
        @progress.loading(model)
        ResponseSet.transaction do
          model.all(:limit => BLOCK_SIZE, :offset => offset).each do |instance|
            create_or_update_response_set_for_primary_record(instance)
          end
        end
        offset += BLOCK_SIZE
      end
    end

    def record_response_set_access_code(record)
      [record.class.mdes_table_name, record.key.first].join('#')
    end

    def create_or_update_response_set_for_primary_record(record)
      survey = Survey.mdes_surveys_by_mdes_table[record.class.mdes_table_name] ||
        fail("No survey for #{record}")
      access_code = record_response_set_access_code(record)
      @progress.increment_response_sets
      # TODO: this will not handle incremental imports when the survey
      # definition changes
      response_set = survey.response_sets.find_by_access_code(access_code)
      if response_set
        log.info(
          "Updating existing response set for #{access_code}")
      else
        log.info(
          "Creating new response set for #{access_code}")
        response_set = ResponseSet.new(
          :survey => survey
        ).tap do |rs|
          rs.instrument_id = core_instrument_id(record.instrument_id),
          rs.access_code = access_code
          rs.save!
        end
      end
      update_response_set_for_record(survey, record, response_set)
    end

    # survey is a param (instead as ref'd from response_set) so that the
    # survey is only loaded once
    def update_response_set_for_record(survey, record, response_set)
      # TODO: this won't work correctly for tables with multiple
      # variants (i.e., fixed values)
      variables = survey.mdes_table_map.
        detect { |ti, tc| tc[:table] == record.class.mdes_table_name }.last[:variables]
      variables.select { |var_name, var_m| var_m[:questions] }.collect { |var_name, var_m|
        questions = var_m[:questions]

        if questions.size > 1
          log.info("%s.%s maps to multiple questions (%s) in %s. Will create duplicate responses." % [
              record.class.mdes_table_name,
              var_name,
              questions.collect { |q| q.reference_identifier }.join(', '),
              survey.title
            ])
        end
        questions.collect { |q| { :question => q, :value => record.send(var_name) } }
      }.flatten.select { |e| e[:value] }.tap { |data|
        exclude_extra_other_values(survey, data)
      }.each do |entry|
        create_or_update_response(response_set, entry[:question], record, entry[:value])
      end

      # find child records
      @wh_config.models_module.mdes_order.collect { |model|
        [model, model.relationships.find { |rel| rel.parent_model == record.class }]
      }.select { |model, rel| rel }.collect { |child_model, rel|
        child_model.all(rel.child_key.first.name => record.key.first)
      }.flatten.each do |child_record|
        update_response_set_for_record(survey, child_record, response_set)
      end
    end

    def create_or_update_response(response_set, question, record, value)
      response = response_set.responses.find { |r|
        r.question_id == question.id &&
          r.source_mdes_table == record.class.mdes_table_name &&
          r.source_mdes_id == record.key.first
      }
      unless response
        response = response_set.responses.build.tap { |r|
          r.question = question
          r.source_mdes_record = record
        }
      end

      update_response(question, response, value)
      response.save! if response.answer
    end

    # question is a param (instead as ref'd from response) so that the
    # answers are only loaded once
    def update_response(question, response, mdes_value)
      @progress.increment_responses

      answers = question.answers
      coded_ref_id = mdes_value.sub(/^-/, 'neg_')
      if coded_a = answers.detect { |a| a.reference_identifier == coded_ref_id }
        response.answer = coded_a
      elsif %w(-3 -4).include?(mdes_value)
        # ignore "Missing in Error" or "Legitimate Skip" if not an explicit response option
      elsif string_a = answers.detect { |a| a.response_class == 'string' }
        response.answer = string_a
        response.string_value = mdes_value
      elsif int_a = answers.detect { |a| a.response_class == 'integer' }
        response.answer = int_a
        response.integer_value = mdes_value.to_i
      elsif dt_a = answers.detect { |a| a.response_class == 'datetime' }
        begin
          response.datetime_value = Time.iso8601(mdes_value)
          response.answer = dt_a
        rescue
          log.error("Ignoring unparsable datetime value %s for question %s in %s" % [
              mdes_value.inspect,
              response.question.reference_identifier,
              response.question.survey_section.survey.title
            ])
        end
      else
        log.error("Unable to map %s to a response for question %s in %s" % [
            mdes_value.inspect,
            response.question.reference_identifier,
            response.question.survey_section.survey.title
          ])
      end
    end

    def core_instrument_id(instrument_public_id)
      core_instrument_id_map[instrument_public_id]
    end

    def core_instrument_id_map
      @core_instrument_id_map ||=
        ActiveRecord::Base.connection.
        select_all('SELECT id, instrument_id AS public_id FROM instruments').
        inject({}) { |h, rec| h[rec['public_id']] = rec['id']; h }
    end

    ##
    # Takes a list of maps of the structure
    # { :question => q, :value => v } and looks for "other"
    # questions. If an "other" question is present, it removes it
    # unless the corresponding coded question is present with the
    # correct value ('-5').
    def exclude_extra_other_values(survey, data)
      data.reject! { |entry|
        pair = survey.mdes_other_pairs.detect { |pair| pair[:other] == entry[:question] }
        if pair
          data.
            select { |entry| entry[:question] == pair[:coded] }.
            select { |entry| entry[:value] == '-5' }.empty?
        else
          false
        end
      }
    end

    # @private
    class ProgressTracker
      extend Forwardable

      def_delegators :@wh_config, :shell

      def initialize(wh_config)
        @wh_config = wh_config
        @response_set_count = 0
        @response_count = 0
        @instr_table_len = Survey.mdes_primary_instrument_tables.collect(&:size).max
      end

      def loading(from_model)
        @current_model = from_model
        show_loading_message
      end

      def start
        @start = Time.now
      end

      def increment_responses
        @response_count += 1
        show_status_message
      end

      def increment_response_sets
        @response_set_count += 1
        show_status_message
      end

      def complete
        shell.clear_line_then_say(
          "Imported or updated %d response set%s and %d response%s in %d seconds (%.2f/sec)\n" % [
            @response_set_count, ('s' if @response_set_count != 1),
            @response_count, ('s' if @response_count != 1),
            elapsed, response_rate
          ]
        )
      end

      def show_status_message
        shell.clear_line_then_say(
          "<- instruments from %#{@instr_table_len}s | %d sets / %d resp (%.1f/sec)" % [
            @current_model.try(:mdes_table_name),
            @response_set_count, @response_count, response_rate
          ]
        )
      end

      def show_loading_message
        shell.clear_line_then_say(
          "Importing instruments from %#{@instr_table_len}s | %d sets / %d resp [loading]" % [
            @current_model.try(:mdes_table_name),
            @response_set_count, @response_count, response_rate
          ]
        )
      end

      def response_rate
        @response_count / elapsed
      end

      def elapsed
        (Time.now - @start)
      end
    end
  end
end
