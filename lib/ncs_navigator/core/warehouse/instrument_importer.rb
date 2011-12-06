require 'ncs_navigator/core'

require 'forwardable'

module NcsNavigator::Core::Warehouse
  class InstrumentImporter
    extend Forwardable

    BLOCK_SIZE = 2500

    def_delegators :@wh_config, :shell, :log

    def initialize(wh_config)
      @wh_config = wh_config
    end

    def import
      Survey.mdes_primary_instrument_tables.each do |primary|
        create_or_update_response_sets_for_model(
          @wh_config.models_module.mdes_order.detect { |model| model.mdes_table_name == primary })
      end
    end

    private

    def create_or_update_response_sets_for_model(model)
      count = model.count
      offset = 0
      while offset < count
        model.all(:limit => BLOCK_SIZE, :offset => offset).each do |instance|
          create_or_update_response_set_for_primary_record(instance)
        end
        offset += BLOCK_SIZE
      end
    end

    def create_or_update_response_set_for_primary_record(record)
      survey = Survey.mdes_surveys_by_mdes_table[record.class.mdes_table_name] ||
        fail("No survey for #{record}")
      # TODO: this will not handle incremental imports when the survey
      # definition changes
      existing = survey.response_sets.find_by_access_code(record.key.first)
      if existing
        update_response_set_for_record(record, existing)
      else
        new_rs = survey.response_sets.build.tap do |rs|
          rs.access_code = record.key.first
          rs.instrument = Instrument.find_by_instrument_id(record.instrument_id)
          rs.save!
        end
        update_response_set_for_record(record, new_rs)
      end
    end

    def update_response_set_for_record(record, response_set)
      # TODO: this won't work correctly for tables with multiple
      # variants (i.e., fixed values)
      variables = response_set.survey.mdes_table_map.
        detect { |ti, tc| tc[:table] == record.class.mdes_table_name }.last[:variables]
      variables.select { |var_name, var_mapping| var_mapping[:questions] }.each do |var_name, var_m|
        questions = var_m[:questions]
        if questions.size > 1
          fail "The importer does not work with variables that map to multiple questions (#{record.class.mdes_table_name}.#{var_name})"
        end
        create_or_update_response(response_set, questions.first, record, var_name)
      end

      # find child records
      @wh_config.models_module.mdes_order.collect { |model|
        [model, model.relationships.find { |rel| rel.parent_model == record.class }]
      }.select { |model, rel| rel }.collect { |child_model, rel|
        child_model.all(rel.child_key.first.name => record.key.first)
      }.flatten.each do |child_record|
        update_response_set_for_record(child_record, response_set)
      end
    end

    def create_or_update_response(response_set, question, record, variable)
      value = record.send(variable)
      return unless value

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

      update_response(response, value)
      response.save!
    end

    def update_response(response, mdes_value)
      answers = response.question.answers
      coded_ref_id = mdes_value.sub(/^-/, 'neg_')
      if coded_a = answers.detect { |a| a.reference_identifier == coded_ref_id }
        response.answer = coded_a
      elsif string_a = answers.detect { |a| a.response_class == 'string' }
        response.answer = string_a
        response.string_value = mdes_value
      elsif int_a = answers.detect { |a| a.response_class == 'integer' }
        response.answer = int_a
        response.integer_value = mdes_value.to_i
      elsif dt_a = answers.detect { |a| a.response_class == 'datetime' }
        response.answer = dt_a
        response.datetime_value = Time.iso8601(mdes_value)
      else
        fail("Unable to map %s to a response for question %s in %s" % [
            mdes_value.inspect,
            response.question.reference_identifier,
            response.question.survey_section.survey.title
          ])
      end
    end
  end
end
