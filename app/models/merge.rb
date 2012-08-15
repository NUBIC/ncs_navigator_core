# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: merges
#
#  completed_at    :datetime
#  conflict_report :text
#  crashed_at      :datetime
#  created_at      :datetime
#  fieldwork_id    :integer
#  id              :integer          not null, primary key
#  log             :text
#  proposed_data   :text
#  started_at      :datetime
#  updated_at      :datetime
#

require 'case'
require 'logger'
require 'ncs_navigator/core'
require 'stringio'

##
# A Merge represents a merge of {Fieldwork} data into Core.  It stores the
# proposed data and metadata such as the merge status, log, and conflict
# report.
class Merge < ActiveRecord::Base
  belongs_to :fieldwork, :inverse_of => :merges

  composed_of :conflict_report, :mapping => %w(conflict_report to_s),
                                :allow_nil => true,
                                :converter => lambda { |raw| ConflictReport.new(raw) }

  delegate :original_data, :to => :fieldwork

  S = Case::Struct.new(:started_at, :completed_at, :crashed_at, :synced_at, :conflicted?, :timed_out?)
  N = Case::Not

  TIMEOUT = 5.minutes

  ##
  # Merges a fieldwork set with Core's datastore.  The log of the operation
  # is written to #log.
  #
  # The merge only proceeds if both JSON objects in original_data and
  # received_data conform to the fieldwork data schema.
  #
  # If the merge completed and all affected entities were saved, returns true.
  # Otherwise, returns false.
  #
  # NOTE: This means that this method may return  true _even if there are
  # conflicts_, so you _cannot_ use the return value of this method to
  # determine whether or not conflicts exist.  Use {#conflicted?} and
  # {#conflict_report} instead.
  #
  #
  # Merge timeout
  # =============
  #
  # Merges are expected to complete within 5 minutes.  Merges that take
  # longer than this will be allowed to complete; however, #status will
  # report "timeout" until the merge completes, at which point the status
  # will be updated.  (If, however, the merge process crashes due to an
  # unrecoverable runtime error -- say, killed by the Linux OOM killer --
  # then the status will be "timeout" until the merge is restarted.)
  #
  #
  # Merge status updates
  # ====================
  #
  # This method updates its record several times:
  #
  #     def run
  #       begin
  #         update_attribute(:started_at, Time.now)
  #
  #         ...merge...
  #
  #         self.conflict_report = conflict_report
  #         self.completed_at = Time.now
  #         save(:validate => false)
  #       rescue => e
  #         update_attribute(:crashed_at, Time.now) rescue nil
  #         raise e
  #       ensure
  #         update_attribute(:log, the_merge_log)
  #       end
  #     end
  #
  # It is very possible that an exception will put the database connection
  # into a state where commands will be ignored.  In this case, the error
  # flag will not be set and the merge will timeout.
  def run
    sio = StringIO.new
    logger = ::Logger.new(sio).tap { |l| l.formatter = ::Logger::Formatter.new }
    logger.level = ::Logger.const_get(NcsNavigatorCore.sync_log_level)

    begin
      # Reset timestamps.
      self.started_at = Time.now
      self.crashed_at = nil
      self.completed_at = nil
      self.synced_at = nil
      save(:validate => false)

      # Check fieldwork schema conformance.
      conformant = check_conformance(logger)

      if !conformant
        update_attribute(:crashed_at, Time.now)
        return false
      end

      # Do the merge.
      merged_models = do_merge
      return false unless merged_models

      self.completed_at = Time.now
      self.conflict_report = sp.conflicts.to_json
      save(:validate => false)

      # Sync PSC.
      synced = do_psc_sync(merged_models)
      return false unless synced

      # We're done.
      update_attribute(:synced_at, Time.now)
    rescue => e
      logger.fatal "#{e.class.name}: #{e.message}"
      e.backtrace.each { |l| logger.fatal(l) }

      update_attribute(:crashed_at, Time.now) rescue nil

      raise e
    ensure
      update_attribute(:log, sio.string)
    end
  end

  ##
  # Returns the status of the merge.  This method returns one of these
  # strings:
  #
  # | Value    | Meaning                                                |
  # | conflict | Merge completed with conflicts                         |
  # | error    | Merge not completed due to fatal errors                |
  # | syncing  | Merge completed without conflicts, waiting on PSC sync |
  # | merged   | Merge completed without conflicts                      |
  # | pending  | Merge not started                                      |
  # | timeout  | Merge not completed, but exceeded a timeout threshold; |
  # |          | success unknown                                        |
  # | working  | Merge in progress                                      |
  #
  # A "fatal error" is any error that causes a merge process to crash and can
  # be caught by the Ruby runtime.  Such errors will be present in the merge
  # log.
  def status
    case S[started_at, completed_at, crashed_at, synced_at,  conflicted?, timed_out?]
    when S[nil,        nil,          nil,        Case::Any,  Case::Any,   N[true]   ]; 'pending'
    when S[N[nil],     nil,          nil,        Case::Any,  Case::Any,   N[true]   ]; 'working'
    when S[Case::Any,  nil,          Case::Any,  Case::Any,  Case::Any,   true      ]; 'timeout'
    when S[Case::Any,  N[nil],       nil,        nil,        N[true],     Case::Any ]; 'syncing'
    when S[Case::Any,  N[nil],       nil,        N[nil],     N[true],     Case::Any ]; 'merged'
    when S[Case::Any,  N[nil],       nil,        Case::Any,  true,        Case::Any ]; 'conflict'
    when S[N[nil],     nil,          N[nil],     Case::Any,  Case::Any,   Case::Any ]; 'error'
    end
  end

  def conflicted?
    !conflict_report.blank?
  end

  ##
  # @private
  # @return merged models
  def do_merge
    sp = Field::Superposition.new
    sp.logger = logger
    sp.set_original(JSON.parse(original_data))
    sp.set_proposed(JSON.parse(proposed_data))
    sp.set_current

    sp.build_question_response_sets
    sp.merge

    sp.save
  end

  ##
  # @private
  def check_conformance(logger)
    vs = schema_violations
    ok = vs.values.all? { |v| v.empty? }

    if !ok
      vs[:original_data].each { |v| logger.fatal "[original] #{v}" }
      vs[:proposed_data].each { |v| logger.fatal "[proposed] #{v}" }

      logger.fatal 'Schema violations detected; aborting merge'
    end

    ok
  end

  ##
  # @private
  def do_psc_sync(models)
    false
  end

  ##
  # @private
  def timed_out?
    (Time.now - started_at >= TIMEOUT) if started_at
  end

  def as_json(options = nil)
    { 'status' => status }
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
