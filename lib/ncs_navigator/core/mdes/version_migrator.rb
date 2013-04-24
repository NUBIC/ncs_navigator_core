module NcsNavigator::Core::Mdes
  ##
  # The component which takes an existing Cases deployment and safely
  # updates its MDES version. This may involve stepwise migration through
  # several intermediate versions.
  class VersionMigrator
    ##
    # The objects registered here migrate Cases from one MDES version to the
    # an adjacent one. Each migration object must implement three methods:
    #
    # - #run: the method that actually performs the migration. It must do
    #   everything that's required to safely change Cases from one version to
    #   the next. In addition to whatever version-specific migrations are
    #   required, this includes changing the stored MDES version value and
    #   updating the code lists.
    # - #from: the version this migration expects Cases to be in before it
    #   starts executing.
    # - #to: the version this migration will leave Cases in after #run is complete.
    #
    # @return [Array<#run,#to#from>]
    def self.default_migrations(options={})
      [
        VersionMigrations::TwoZeroToTwoOne.new(options),
        VersionMigrations::TwoOneToTwoTwo.new(options),
        VersionMigrations::TwoTwoToThreeOne.new(options),
        VersionMigrations::ThreeZeroToThreeTwo.new(options)
      ]
    end

    attr_reader :start_version, :known_migrations

    def initialize(options={})
      @interactive = options.delete(:interactive)
      @start_version = options.delete(:start_version) ||
        NcsNavigatorCore.mdes_version.number
      @known_migrations = options.delete(:known_migrations) ||
        self.class.default_migrations(:interactive => @interactive)
    end

    ##
    # Returns the chain of migration instances which take the system from
    # {#start_version} to {target_version}. If no chain can be determined
    # it throws an exception.
    #
    # @param [String] target_version
    # @return [Array<#to,#from,#run>] the migrations to use
    def migrations(target_version)
      unless known_migrations.collect(&:to).include?(target_version)
        fail "There is no migration path to #{target_version} from any version."
      end
      unless known_migrations.collect(&:from).include?(start_version)
        fail "There is no migration path from #{start_version} to any version."
      end

      best_path = migration_paths(start_version, target_version).
        sort_by { |path| path.size }.
        first

      best_path or fail "There is no migration path from #{start_version} to #{target_version}."
    end

    def migration_paths(from, to)
      if sole_migration = known_migrations.find { |m| m.to == to && m.from == from }
        return [[sole_migration]]
      end

      known_migrations.
        select { |m| m.from == from }.
        each_with_object([]) { |m, acc| acc.concat(migration_paths(m.to, to).reject { |sub| sub.empty? }.collect { |sub| [m] + sub }) }.
        select { |path| path.last.try(:to) == to }
    end
    private :migration_paths

    def interactive?
      @interactive
    end
    private :interactive?

    ##
    # Determines the appropriate migrations to execute, then executes them.
    # Throws an exception if no path from {#start_version} to {target_version}.
    #
    # @return [void]
    def migrate!(target_version)
      all = migrations(target_version)

      if interactive?
        steps = [start_version] + migrations(target_version).collect(&:to)
        if steps.size > 2
          $stderr.puts "Migrating from #{steps.first} to #{steps.last} via #{steps[1,steps.size - 2].join(', ')}"
        end
      end

      all.each do |migration|
        $stderr.puts "Migrating from #{migration.from} to #{migration.to}." if interactive?
        migration.run
      end

      if interactive?
        $stderr.puts "MDES version migration complete. Registered MDES version for this deployment is now #{Version.new.number}."
      end
    end
  end
end
