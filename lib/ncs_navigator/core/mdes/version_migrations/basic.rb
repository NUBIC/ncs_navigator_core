require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes::VersionMigrations
  ##
  # A migrator that does the minimum steps that are required for any version
  # change:
  #
  # * Change the code lists to the ones for the new version
  # * Change the stored version number to the new version
  #
  # N.b.: using this migration for a pair of versions is a claim that there are
  # NO semantic modifications of specified values between them. DO NOT use it
  # for any pair of versions without rigorously verifying that this is the case.
  #
  # @see VersionMigrator
  class Basic
    attr_reader :from, :to

    def initialize(from_version, to_version, options={})
      @from = from_version
      @to = to_version
      @interactive = options[:interactive]
    end

    ##
    # Provides the basic behavior documented for the class. Also invokes two
    # template methods which subclasses may implement to provide additional
    # behaviors.
    #
    # - `run_before_code_list_changes`: executed immediately before the code
    #   lists are replaced with the lists for the new version.
    # - `run_after_code_list_changes`: executed immediately after the code lists
    #   are placed with the lists for the new version.
    def run
      original_whodunnit = PaperTrail.whodunnit
      begin
        PaperTrail.whodunnit = self.class.to_s
        ActiveRecord::Base.transaction do
          if self.respond_to?(:run_before_code_list_changes)
            run_before_code_list_changes
          end

          switch_code_lists

          if self.respond_to?(:run_after_code_list_changes)
            run_after_code_list_changes
          end

          change_registered_version
        end
      ensure
        PaperTrail.whodunnit = original_whodunnit
      end
    end

    def switch_code_lists
      NcsNavigator::Core::MdesCodeListLoader.
        new(:mdes_version => to, :interactive => @interactive).
        load_from_yaml
    end
    protected :switch_code_lists

    def change_registered_version
      NcsNavigator::Core::Mdes::Version.change!(to)
    end
    protected :change_registered_version
  end
end
