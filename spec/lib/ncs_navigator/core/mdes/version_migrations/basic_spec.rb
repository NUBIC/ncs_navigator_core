require 'spec_helper'

module NcsNavigator::Core::Mdes::VersionMigrations
  # clean_with_truncation because CodeListLoader#load_from_pg_dump hangs
  # when there's an open transaction that's touched ncs_codes.
  describe Basic, :clean_with_truncation do
    let(:migrator) { Basic.new(NcsNavigatorCore.mdes_version.number, '2.2') }

    describe '#initialize' do
      it 'sets #from' do
        migrator.from.should == NcsNavigatorCore.mdes_version.number
      end

      it 'sets #to' do
        migrator.to.should == '2.2'
      end
    end

    describe '#run' do
      before do
        NcsNavigator::Core::Mdes::Version.set!(migrator.from)
        migrator.run
      end

      after do
        # restore the code list to the current version
        NcsNavigator::Core::Mdes::CodeListLoader.new.load_from_pg_dump
      end

      it 'updates the MDES version in the database' do
        NcsNavigator::Core::Mdes::Version.new.number.should == migrator.to
      end

      let(:target_version_code_lists) {
        NcsNavigator::Core::Mdes::CodeListLoader.new(:mdes_version => migrator.to).yaml_entries.
          collect { |code| code['list_name'] }.uniq.sort
      }

      def select_one_column(query)
        ActiveRecord::Base.connection.select_all(query).
          collect { |row| row.values.first }
      end

      it "changes the code lists to the targeted version's lists" do
        select_one_column("SELECT DISTINCT list_name FROM ncs_codes").sort.
          should == target_version_code_lists
      end
    end
  end
end
