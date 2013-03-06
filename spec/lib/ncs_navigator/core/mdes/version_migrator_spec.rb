require 'spec_helper'

module NcsNavigator::Core::Mdes
  describe VersionMigrator do
    def dummy_migration(from, to)
      stub("dummy_migration #{from} -> #{to}").tap do |m|
        m.stub!(:from => from, :to => to)
      end
    end

    describe '#initialize' do
      before do
        NcsNavigatorCore.stub!(:mdes_version => Version.new('1.1'))
      end

      describe ':start_version' do
        it 'can be set' do
          VersionMigrator.new(:start_version => '7.8').start_version.should == '7.8'
        end

        it 'defaults to the current deployed version' do
          VersionMigrator.new.start_version.should == '1.1'
        end
      end

      describe ':known_migrations' do
        it 'can be set' do
          VersionMigrator.new(:known_migrations => [dummy_migration('3', 'forks'), dummy_migration('tacos', '8')]).
            known_migrations.collect(&:from).should == %w(3 tacos)
        end

        it 'defaults to the list returned by .default_migrations' do
          expected_defaults = VersionMigrator.default_migrations.collect { |m| [m.from, m.to] }
          actual_defaults   = VersionMigrator.new.known_migrations.collect { |m| [m.from, m.to] }

          actual_defaults.should == expected_defaults
        end
      end
    end

    describe '#migrations' do
      let(:known_migrations) {
        [
          dummy_migration('8.0', '8.1'),
          dummy_migration('8.1', '8.2'),
          dummy_migration('8.2', '8.3'),
          dummy_migration('8.3', '9.0'),
          dummy_migration('8.1', '9.0'),
          dummy_migration('9.0', '9.1'),
          dummy_migration('9.0', '9.2'),
          dummy_migration('9.1', '9.2'),
          dummy_migration('9.1', '10.0'),
          dummy_migration('9.5', '11.0'),
        ]
      }

      let(:options) {
        { :known_migrations => known_migrations, :start_version => '8.1' }
      }

      let(:migrator) {
        VersionMigrator.new(options)
      }

      def series_string(target_version)
        migrator.migrations(target_version).collect { |m| [m.from, m.to].join(" -> ") }.join(", ")
      end

      it 'can find a single migration that matches the request' do
        series_string('9.0').should == "8.1 -> 9.0"
      end

      it 'can find a migration chain that requires several migrations' do
        series_string('8.3').should == "8.1 -> 8.2, 8.2 -> 8.3"
      end

      it 'picks the shortest path when there are several options' do
        series_string('9.2').should == "8.1 -> 9.0, 9.0 -> 9.2"
      end

      it 'throws an exception if there is no migration chain because the target version does not exist' do
        expect { migrator.migrations('9.3') }.to raise_error("There is no migration path to 9.3 from any version.")
      end

      it 'throws an exception if there is no migration chain because there is a missing link' do
        expect { migrator.migrations('11.0') }.to raise_error("There is no migration path from 8.1 to 11.0.")
      end

      it 'throws an exception if there is no migration chain because the start version does not exist' do
        options[:start_version] = '8.5'

        expect { migrator.migrations('9.0') }.to raise_error("There is no migration path from 8.5 to any version.")
      end
    end

    describe '#migrate!' do
      let(:known_migrations) {
        [
          dummy_migration('8.0', '8.1'),
          dummy_migration('8.1', '8.2'),
          m82_83,
          m83_90,
          dummy_migration('8.1', '9.0'),
          m90_91,
          dummy_migration('9.0', '9.2'),
          dummy_migration('9.1', '9.2'),
          dummy_migration('9.1', '10.0'),
          dummy_migration('9.5', '11.0'),
        ]
      }

      let(:options) {
        { :known_migrations => known_migrations, :start_version => '8.2' }
      }

      let(:migrator) {
        VersionMigrator.new(options)
      }

      let(:m82_83) { dummy_migration('8.2', '8.3') }
      let(:m83_90) { dummy_migration('8.3', '9.0') }
      let(:m90_91) { dummy_migration('9.0', '9.1') }

      let(:expected_used_migrations) { [m82_83, m83_90, m90_91] }

      it 'runs exactly the appropriate migrations' do
        # RSpec mocks can't verify order across objects, so this will have to be
        # good enough.
        expected_used_migrations.each { |m| m.should_receive(:run) }
        (known_migrations - expected_used_migrations).each { |m| m.should_not_receive(:run) }

        migrator.migrate!('9.1')
      end
    end
  end
end
