# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: merges
#
#  client_id       :string(255)
#  conflict_report :text
#  crashed_at      :datetime
#  created_at      :datetime
#  fieldwork_id    :integer
#  id              :integer          not null, primary key
#  log             :text
#  merged_at       :datetime
#  proposed_data   :text
#  staff_id        :string(255)
#  started_at      :datetime
#  synced_at       :datetime
#  updated_at      :datetime
#  username        :string(255)      not null
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
  include NcsNavigator::Core::Field

  belongs_to :fieldwork, :inverse_of => :merges

  composed_of :conflict_report, :mapping => %w(conflict_report to_json),
                                :allow_nil => true,
                                :converter => lambda { |raw| ConflictReport.new(raw) }

  delegate :original_data, :to => :fieldwork

  validates_presence_of :client_id
  validates_presence_of :staff_id
  validates_presence_of :username

  S = Case::Struct.new(:started_at, :merged_at, :crashed_at, :synced_at, :conflicted?, :timed_out?)
  N = Case::Not

  TIMEOUT = 5.minutes

  ##
  # Permits customization of the log device used by the merge process.  If not
  # set, a StringIO instance that is dumped into the merge record will be used.
  cattr_accessor :log_device

  ##
  # If stubbed to return false, PSC sync will not be done.
  def self.sync_with_psc?
    true
  end

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
  # Merge restarts and ODEs
  # =======================
  #
  # Failing merges may be restarted freely until they pass.  Merges that have
  # completed can be restarted, but may result in operational data conflicts.
  # The reason is that the merge process currently has no visibility into the
  # operational data extractors and what they change: as far as merge is
  # concerned, the ODEs are another user making changes to operational data
  # which may or may not jive with what's coming from Field.
  #
  # In the future, this might be addressed, but doing that is not trivial.
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
  #         self.merged_at = Time.now
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
    logdev = LogDevice.new(self.class.log_device || StringIO.new)
    logger = ::Logger.new(logdev).tap { |l| l.formatter = LogFormatter.new(self) }
    logger.level = ::Logger.const_get(NcsNavigatorCore.sync_log_level)

    begin
      # Reset timestamps.
      self.crashed_at = nil
      self.merged_at = nil
      self.started_at = Time.now
      self.synced_at = nil
      save(:validate => false)

      # Check fieldwork schema conformance.
      conformant = check_conformance(logger)

      if !conformant
        update_attribute(:crashed_at, Time.now)
        return false
      end

      # Do the merge.

      self.class.transaction do
        superposition = do_merge(logger)

        if !superposition
          update_attribute(:crashed_at, Time.now)
          logger.fatal { 'Merge failed, rolling back' }
          raise ActiveRecord::Rollback
        else
          self.merged_at = Time.now
          self.conflict_report = superposition.conflicts
          save(:validate => false)

          # TODO: cf. #3734
          # check if the participant is eligible and/or
          # send person to EligibilityAdjudicator
          # Is this the correct place to do this?

          if self.class.sync_with_psc?
            # Sync current state...
            superposition.prepare_for_sync(self)
            superposition.sync_with_psc

            # ...and schedule new events.
            superposition.advance_participant_schedules
            update_attribute(:synced_at, Time.now)
          else
            true
          end
        end
      end
    rescue Exception => e
      logger.fatal { "#{e.class.name}: #{e.message}" }
      logger.fatal { e.backtrace.join("\n") }

      update_attribute(:crashed_at, Time.now) rescue nil

      raise e
    ensure
      logdev.rewind
      update_attribute(:log, logdev.read)
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
  def status(as_of = Time.now)
    case S[started_at, merged_at, crashed_at, synced_at,  conflicted?, timed_out?(as_of)]
    when S[nil,        nil,       nil,        Case::Any,  Case::Any,   N[true]          ]; 'pending'
    when S[N[nil],     nil,       nil,        Case::Any,  Case::Any,   N[true]          ]; 'working'
    when S[Case::Any,  nil,       Case::Any,  Case::Any,  Case::Any,   true             ]; 'timeout'
    when S[Case::Any,  N[nil],    nil,        nil,        N[true],     Case::Any        ]; 'syncing'
    when S[Case::Any,  N[nil],    nil,        N[nil],     N[true],     Case::Any        ]; 'merged'
    when S[Case::Any,  N[nil],    nil,        Case::Any,  true,        Case::Any        ]; 'conflict'
    when S[Case::Any,  Case::Any, N[nil],     Case::Any,  Case::Any,   Case::Any        ]; 'error'
    end
  end

  def conflicted?
    !conflict_report.blank?
  end

  ##
  # @private
  # @return [Field::Superposition, nil]
  def do_merge(logger)
    sp = Field::Superposition.new
    sp.logger = logger
    sp.responsible_user = username
    sp.staff_id = staff_id
    sp.build(JSON.parse(original_data), JSON.parse(proposed_data))

    sp.merge

    ok = sp.save

    sp if ok
  end

  ##
  # @private
  def check_conformance(logger)
    vs = schema_violations
    ok = vs.values.all? { |v| v.empty? }

    if !ok
      vs[:original_data].each { |e| logger.fatal "[original] #{e.inspect}" }
      vs[:proposed_data].each { |e| logger.fatal "[proposed] #{e.inspect}" }

      logger.fatal 'Schema violations detected; aborting merge'
    end

    ok
  end

  ##
  # @private
  def timed_out?(as_of)
    (as_of - started_at >= TIMEOUT) if started_at
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
    validator = NcsNavigator::Core::Field::JSONValidator.new

    {
      :original_data => validator.validate(original_data || '{}').errors,
      :proposed_data => validator.validate(proposed_data || '{}').errors
    }
  end
end
