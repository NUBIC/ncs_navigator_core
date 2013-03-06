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

    def initialize(from_version, to_version)
      @from = from_version
      @to = to_version
    end

    def run
      ActiveRecord::Base.transaction do
        switch_code_lists
        change_registered_version
      end
    end

    def switch_code_lists
      NcsNavigator::Core::MdesCodeListLoader.
        new(:mdes_version => to, :interactive => true).
        load_from_yaml
    end
    protected :switch_code_lists

    def change_registered_version
      NcsNavigator::Core::Mdes::Version.change!(to)
    end
    protected :change_registered_version
  end
end
