# -*- coding: utf-8 -*-


require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  module InstrumentToWarehouse
    STATIC_RECORD_FIELD_MAPPING = {
      :event_id => 'event.public_id',
      :event_type => 'event.event_type_code',
      :event_repeat_key => 'event.event_repeat_key',
      :instrument_id => 'public_id',
      :instrument_version => 'instrument_version',
      :instrument_repeat_key => 'instrument_repeat_key',
      :instrument_type => 'instrument_type_code',
    }

    ##
    # Produces one or more MDES Warehouse model instances from the
    # responses in this response set.
    def to_mdes_warehouse_records(wh_config)
      table_serials = Hash.new(0)

      records = response_bins.collect do |response_bin|
        serial = (table_serials[response_bin.table_name] += 1)

        response_bin.create_record(self, wh_config, serial)
      end.flatten.tap { |records| wh_resolve_internal_references(records) }
    end

    ##
    # The combined table map for all the surveys used in this instrument.
    # @see {MdesInstrumentSurvey#mdes_table_map}
    def mdes_table_map
      @mdes_table_map ||= Survey.merge_mdes_table_maps(response_sets.collect(&:survey).uniq)
    end

    protected

    def responses
      response_sets.includes(:participant, :survey).
        collect { |rs| rs.responses.includes(:question) }.flatten
    end

    private

    ##
    # Bins all the responses for this instrument by table identifier and
    # participant, ensuring that every question is only answered once per bin.
    #
    # @return [Array<ResponseBin>]
    def response_bins
      @response_bins ||= begin
        by_ident = responses.inject({}) { |h, r|
          table_ident = mdes_table_map.find { |table_ident, table_contents|
            table_contents[:variables].detect { |var_name, var_mapping|
              var_mapping[:questions] && var_mapping[:questions].include?(r.question)
            }
          }.try(:first)
          if table_ident
            h[table_ident] ||= []
            wh_partition_response(r, table_ident, h[table_ident])
          end
          h
        }

        by_ident.values.flatten.sort { |binA, binB|
          a = binA.table_content[:primary]
          b = binB.table_content[:primary]
          if a
            b ?  0 : -1
          else
            b ?  1 :  0
          end
        }
      end
    end

    ##
    # Finds the appropriate set of responses for this response out of
    # the list of bins, or adds a new bin and adds this response to
    # it.
    #
    # @return [void]
    def wh_partition_response(response, table_ident, bins)
      should_be_in_same_bin_as = [
        corresponding_same_table_other_for_coded(response),
        corresponding_same_table_coded_for_other(response)
      ].compact.first

      target_bin =
        if should_be_in_same_bin_as
          bins.find { |bin| bin.detect { |r| r == should_be_in_same_bin_as } }
        else
          bins.reject { |bin|
            # bins are per-participant
            bin.participant.p_id != response.response_set.participant.p_id ||
            # and must have only one response per question
            bin.detect { |r| r.question == response.question }
          }.first
        end

      if target_bin
        target_bin << response
      elsif bins.last && bins.last.empty?
        bins.last << response
      else
        bins << ResponseBin.new(
          response.response_set.participant, table_ident,
          mdes_table_map[table_ident], [response])
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
        other_q = response.response_set.survey.mdes_other_pairs.
          find { |pair| pair[:coded] == response.question }.try(:[], :other)
        if other_q
          response.response_set.responses.find_by_question_id(other_q.id)
        end
      end
    end

    ##
    # Performs the converse of {#corresponding_same_table_other_for_coded}.
    def corresponding_same_table_coded_for_other(response)
      coded_q = response.response_set.survey.mdes_other_pairs.
        find { |pair| pair[:other] == response.question }.try(:[], :coded)
      if coded_q
        response.response_set.responses.find_all_by_question_id(coded_q.id).
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

    ##
    # @private
    #
    # This class is a collection of responses for the same participant and MDES
    # table.
    class ResponseBin
      include Enumerable

      extend Forwardable
      def_delegators :responses, :each, :empty?

      # not a struct because structs can't mix in enumerable usefully
      attr_reader :participant, :table_identifier, :table_content, :responses

      def initialize(participant, table_ident, table_content, responses=[])
        @participant = participant
        @table_identifier = table_ident
        @table_content = table_content
        @responses = responses
      end

      def <<(response)
        self.responses << response
      end

      ##### RESPONSE ANALYSIS

      def response_sets
        responses.collect(&:response_set).uniq
      end

      def questions
        response_sets.collect(&:survey).collect(&:sections_with_questions).
          collect { |sections| sections.collect(&:questions) }.flatten
      end

      def is_unanswered?(q)
        response_set_for_question(q).try(:is_unanswered?, q)
      end

      def response_set_for_question(q)
        response_sets.detect { |rs| rs.survey.sections_with_questions.collect(&:questions).flatten.include?(q) }
      end
      private :response_set_for_question

      def missing_questions
        response_sets.collect { |rs|
          rs.unanswered_dependencies.collect { |dep|
            case dep
            when Question; dep;
            when QuestionGroup; dep.questions
            end
          }
        }.flatten
      end

      def unanswered_exported_questions
        questions.select { |q| is_unanswered?(q) && exported_question?(q) }
      end

      def variable_name_for_question(q)
        table_content[:variables].
          find { |var_name, var_mapping| (var_mapping[:questions] || []).include?(q) }.try(:first)
      end

      def exported_question?(q)
        variable_name_for_question(q)
      end
      private :exported_question?

      ###### RECORD CREATION

      def create_record(instrument, wh_config, serial)
        create_base_record(instrument, wh_config, serial).tap do |record|
          apply_response_values(record)
          set_missing_values(record)
        end
      end

      def create_base_record(instrument, wh_config, serial)
        model = wh_config.model(table_name)
        model.new.tap do |record|
          record.send("#{model.key.first.name}=", record_id(serial))
          STATIC_RECORD_FIELD_MAPPING.each do |record_attribute, rs_attribute|
            setter = "#{record_attribute}="
            if record.respond_to?(setter)
              record.send(setter, resolve_nested_attribute(rs_attribute, instrument))
            end
          end
          fixed_values.each do |record_attribute, value|
            record.send("#{record_attribute}=", value)
          end
          if record.respond_to?(:p_id=)
            record.p_id = participant.p_id
          end
        end
      end
      private :create_base_record

      def resolve_nested_attribute(path, object)
        return nil unless object
        attr, subpath = path.split('.', 2)
        if subpath
          resolve_nested_attribute(subpath, object.send(attr))
        else
          object.send(attr)
        end
      end
      private :resolve_nested_attribute

      def apply_response_values(record)
        each do |r|
          variable_name = variable_name_for_question(r.question)
          record.send("#{variable_name}=", r.reportable_value)
        end
      end
      private :apply_response_values

      def set_missing_values(record)
        unanswered_exported_questions.each do |q|
          variable_name = variable_name_for_question(q)
          if variable_name && record.class.properties[variable_name].required?
            set_first_valid(record, variable_name, select_possible_missing_codes(q))
          end
        end
      end
      private :set_missing_values

      def set_first_valid(record, variable_name, possible_values)
        record.send("#{variable_name}=", possible_values.shift)
        unless record.class.validators[variable_name.to_sym].all? { |v| v.call(record) }
          if possible_values.empty?
            Rails.logger.error("Unable to find a valid value for #{record.class.mdes_table_name}##{variable_name}")
          else
            set_first_valid(record, variable_name, possible_values)
          end
        end
      end
      private :set_first_valid

      def select_possible_missing_codes(q)
        if missing_questions.include?(q)
          # Missing in error
          %w(-4)
        else
          # Legitimate skip or Missing in error
          %w(-3 -4)
        end
      end
      private :select_possible_missing_codes

      def fixed_values
        table_content[:variables].inject({}) { |h, (var_name, var_mapping)|
          h[var_name] = var_mapping[:fixed_value] if var_mapping[:fixed_value]
          h
        }
      end
      private :fixed_values

      def table_name
        table_content[:table]
      end

      def imported_id
        select { |r| r.source_mdes_table == table_name }.
          collect { |r| r.source_mdes_id }.compact.first
      end
      private :imported_id

      def record_id_base
        response_sets.sort_by(&:created_at).first.access_code
      end
      private :record_id_base

      def record_id(serial)
        imported_id || "#{record_id_base}.#{serial}"
      end
      private :record_id
    end
  end
end

::Instrument.send(:include, NcsNavigator::Core::Warehouse::InstrumentToWarehouse)
