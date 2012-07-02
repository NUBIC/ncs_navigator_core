

require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  module ResponseSetToWarehouse
    ## TODO: centralize MDES version selection
    MdesModule = NcsNavigator::Warehouse::Models::TwoPointZero

    STATIC_RECORD_FIELD_MAPPING = {
      :event_id => 'instrument.event.public_id',
      :event_type => 'instrument.event.event_type_code',
      :event_repeat_key => 'instrument.event.event_repeat_key',
      :instrument_id => 'instrument.public_id',
      :instrument_version => 'instrument.instrument_version',
      :instrument_repeat_key => 'instrument.instrument_repeat_key',
      :instrument_type => 'instrument.instrument_type_code',
      :p_id => 'instrument.event.participant.public_id'
    }

    ##
    # Produces one or more MDES Warehouse model instances from the
    # responses in this response set.
    def to_mdes_warehouse_records
      table_map = self.survey.mdes_table_map
      responses_by_table_ident = responses.includes(:question).inject({}) do |h, r|
        table_ident = table_map.find { |table_ident, table_contents|
          table_contents[:variables].detect { |var_name, var_mapping|
            var_mapping[:questions] && var_mapping[:questions].include?(r.question)
          }
        }.try(:first)
        if table_ident
          h[table_ident] ||= [[]]
          wh_partition_response(r, h[table_ident])
        end
        h
      end

      # This is all the questions whose dependencies are met but which
      # do not have any answers.
      missing_questions = unanswered_dependencies.collect { |dep|
        case dep
        when Question; dep;
        when QuestionGroup; dep.questions
        end
      }.flatten

      records = responses_by_table_ident.sort { |(tiA, rlA), (tiB, rlB)|
        a = table_map[tiA][:primary]
        b = table_map[tiB][:primary]
        if a
          b ?  0 : -1
        else
          b ?  1 :  0
        end
      }.collect do |ti, response_lists|
        table = table_map[ti][:table]
        fixed_map = table_map[ti][:variables].inject({}) { |h, (var_name, var_mapping)|
          h[var_name] = var_mapping[:fixed_value] if var_mapping[:fixed_value]
          h
        }
        table_ct = 0
        response_lists.collect do |responses|
          table_ct += 1
          imported_id =
            responses.select { |r| r.source_mdes_table == table }.
              collect { |r| r.source_mdes_id }.compact.first

          unanswered_for_table = survey.sections_with_questions.collect(&:questions).flatten.
            select { |q| is_unanswered?(q) && variable_for_question_in_table(table_map[ti], q) }.
            inject({'-4' => [], '-3' => []}) { |map, q|
              if missing_questions.include?(q)
                # Missing in error
                map['-4'] << q
              else
                # Legitimate skip
                map['-3'] << q
              end
              map
            }

          wh_create_base_record(table, imported_id, table_ct, fixed_map).tap do |record|
            responses.each do |r|
              variable_name = table_map[ti][:variables].detect { |var_name, var_mapping|
                var_mapping[:questions] && var_mapping[:questions].include?(r.question)
              }.first
              record.send("#{variable_name}=", r.reportable_value)
            end
            unanswered_for_table.each do |code, qs|
              qs.each do |q|
                variable_name, dc = table_map[ti][:variables].detect { |var_name, var_mapping|
                  var_mapping[:questions] && var_mapping[:questions].include?(q)
                }
                codes = if code == '-3'
                          %w(-3 -4)
                        else
                          [code]
                        end
                if variable_name && record.class.properties[variable_name].required?
                  wh_set_first_valid(record, variable_name, codes)
                end
              end
            end
          end
        end
      end.flatten.tap { |records| wh_resolve_internal_references(records) }
    end

    protected

    private

    def wh_create_base_record(table_name, imported_id, serial, fixed_values)
      model = MdesModule.mdes_order.detect { |m| m.mdes_table_name == table_name }
      model.new.tap do |record|
        id = imported_id ? imported_id : "#{access_code}.#{serial}"
        record.send("#{model.key.first.name}=", id)
        STATIC_RECORD_FIELD_MAPPING.each do |record_attribute, rs_attribute|
          setter = "#{record_attribute}="
          if record.respond_to?(setter)
            record.send(setter, resolve_nested_attribute(rs_attribute))
          end
        end
        fixed_values.each do |record_attribute, value|
          record.send("#{record_attribute}=", value)
        end
      end
    end

    def resolve_nested_attribute(path, object=self)
      return nil unless object
      attr, subpath = path.split('.', 2)
      if subpath
        resolve_nested_attribute(subpath, object.send(attr))
      else
        object.send(attr)
      end
    end

    # returns [variable_name, variable_mapping] out of table_map
    def variable_for_question_in_table(table_context, question)
      table_context[:variables].detect { |var_name, var_mapping|
        var_mapping[:questions] && var_mapping[:questions].include?(question)
      }
    end

    def wh_set_first_valid(record, variable_name, possible_values)
      record.send("#{variable_name}=", possible_values.shift)
      unless record.class.validators[variable_name.to_sym].all? { |v| v.call(record) }
        if possible_values.empty?
          Rails.logger.error("Unable to find a valid value for #{record.class.mdes_table_name}##{variable_name}")
        else
          wh_set_first_valid(record, variable_name, possible_values)
        end
      end
    end

    ##
    # Finds the appropriate set of responses for this response out of
    # the list of bins, or adds a new bin and adds this response to
    # it.
    #
    # @return [void]
    def wh_partition_response(response, bins)
      should_be_in_same_bin_as = [
        corresponding_same_table_other_for_coded(response),
        corresponding_same_table_coded_for_other(response)
      ].compact.first

      target_bin =
        if should_be_in_same_bin_as
          bins.find { |rs| rs.detect { |r| r == should_be_in_same_bin_as } }
        else
          bins.reject { |rs| rs.detect { |r| r.question == response.question } }.first
        end

      if target_bin
        target_bin << response
      elsif bins.last.empty?
        bins.last << response
      else
        bins << [response]
      end
    end

    ##
    # If this response is a coded question where the coded is "other"
    # (-5), finds the response (if any) which contains the
    # corresponding "other" text, IFF the corresponding "other" text
    # is in the same MDES table as the coded question.
    #
    # @see MdesInstrumentSurvey#mdes_other_pairs
    def corresponding_same_table_other_for_coded(response)
      if response.answer.reference_identifier == 'neg_5'
        other_q = survey.mdes_other_pairs.
          find { |pair| pair[:coded] == response.question }.try(:[], :other)
        if other_q
          responses.find_by_question_id(other_q.id)
        end
      end
    end

    ##
    # Performs the converse of {#corresponding_same_table_other_for_coded}.
    def corresponding_same_table_coded_for_other(response)
      coded_q = survey.mdes_other_pairs.
        find { |pair| pair[:other] == response.question }.try(:[], :coded)
      if coded_q
        responses.find_all_by_question_id(coded_q.id).
          find { |res| res.answer.reference_identifier == 'neg_5' }
      end
    end

    ##
    # Attempts to resolve any references in the given list of records
    # with the other records in the list. If more than one could be
    # used, the first match is used. TODO: this will not work
    # correctly for tertiary associations (#1653).
    def wh_resolve_internal_references(records)
      records.each do |rec|
        rec.class.relationships.each do |rel|
          parent = records.detect { |cand| cand.class == rel.parent_model }
          rec.send("#{rel.name}=", parent) if parent
        end
      end
    end
  end
end

::ResponseSet.send(:include, NcsNavigator::Core::Warehouse::ResponseSetToWarehouse)
