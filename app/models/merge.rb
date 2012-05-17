# -*- coding: utf-8 -*-

require 'logger'
require 'ncs_navigator/core'
require 'stringio'

##
# A Merge represents a merge of {Fieldwork} data into Core.  It stores the
# proposed data and metadata such as the merge status, log, and conflict
# report.
class Merge < ActiveRecord::Base
  belongs_to :fieldwork, :inverse_of => :merges

  delegate :original_data, :to => :fieldwork

  ##
  # Merges a fieldwork set with Core's datastore.  The log of the operation is
  # written to #merge_log.  If the merge completes without conflicts, #merged
  # will be set to true; otherwise, #merged will be false and the conflicts
  # will be in the merge log.
  #
  # The merge only proceeds if both JSON objects in original_data and
  # received_data conform to the fieldwork data schema.
  #
  # If the merge completed without conflicts and all data was saved, returns
  # true; otherwise, returns false.
  def run
    begin
      sio = StringIO.new
      logger = ::Logger.new(sio).tap { |l| l.formatter = ::Logger::Formatter.new }
      logger.level = ::Logger.const_get(NcsNavigatorCore.sync_log_level)

      violations = schema_violations

      unless violations.values.all? { |v| v.empty? }
        violations[:original_data].each do |violation|
          logger.fatal { "[original] #{violation}" }
        end
        violations[:proposed_data].each do |violation|
          logger.fatal { "[proposed] #{violation}" }
        end

        logger.fatal { "Schema violations detected; aborting merge" }

        return
      end

      sp = NcsNavigator::Core::Fieldwork::Superposition.new
      sp.logger = logger
      sp.set_original(JSON.parse(original_data))
      sp.set_proposed(JSON.parse(proposed_data))
      sp.set_current
      sp.group_responses

      sp.merge

      (sp.save unless sp.conflicted?).tap do
        update_attributes(:done => true, :conflict_report => sp.conflicts.to_json)
        save
      end
    ensure
      update_attribute(:log, sio.string)
    end
  end

  def as_json(options = nil)
    { 'status' => 'pending' }
  end

  ##
  # Returns the fieldwork schema violations, if any, in the #original_data
  # and #received_data JSON objects.  The return value is as follows:
  #
  #     {
  #       :original_data => [violations],
  #       :received_data => [violations]
  #     }
  #
  # If either field is blank, then {} is validated in lieu of that field.
  # (At present, this will generate schema errors, but that's acceptable: the
  # lack of an object is arguably a violation.)
  def schema_violations
    validator = NcsNavigator::Core::Fieldwork::Validator.new

    {
      :original_data => validator.fully_validate(JSON.parse(original_data || '{}')),
      :proposed_data => validator.fully_validate(JSON.parse(proposed_data || '{}'))
    }
  end
end
