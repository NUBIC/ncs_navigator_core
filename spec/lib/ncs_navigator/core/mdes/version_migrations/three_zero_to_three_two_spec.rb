require 'spec_helper'

module NcsNavigator::Core::Mdes::VersionMigrations
  # clean_with_truncation because CodeListLoader#load_from_pg_dump hangs
  # when there's an open transaction that's touched ncs_codes.
  describe ThreeZeroToThreeTwo, :clean_with_truncation do
    let(:migration) {
      ThreeZeroToThreeTwo.new
    }

    it 'goes from 3.0' do
      migration.from.should == '3.0'
    end

    it 'goes to 3.2' do
      migration.to.should == '3.2'
    end

    describe '#run' do
      let!(:p_neg4) { Factory(:participant, :p_type_code => -4) }
      let!(:p1) { Factory(:participant, :p_type_code => 1) }
      let!(:p2) { Factory(:participant, :p_type_code => 2) }
      let!(:p3) { Factory(:participant, :p_type_code => 3) }
      let!(:p4) { Factory(:participant, :p_type_code => 4) }
      let!(:p5) { Factory(:participant, :p_type_code => 5) }
      let!(:p6) { Factory(:participant, :p_type_code => 6) }

      before do
        # N.b.: these migrations rely on the new code lists, so stubbing out
        # the code list switch for performance is not possible here.

        NcsNavigator::Core::Mdes::Version.set!(migration.from)
        with_versioning do
          migration.run
        end
      end

      after do
        # restore the code list to the current version
        NcsNavigator::Core::Mdes::CodeListLoader.new.load_from_pg_dump
      end

      describe 'changing p_type' do
        it 'changes eligible pregnant women to PBS Provider participants' do
          p3.reload.p_type_code.should == 14
        end

        it 'leaves all other p_types alone' do
          [p_neg4, p1, p2, p4, p5, p6].collect { |p| p.reload.p_type_code }.
            should == [-4, 1, 2, 4, 5, 6]
        end

        describe 'auditing' do
          let(:preg_woman_revision) { p3.reload.versions.last }
          let(:preg_woman_changes) { YAML.load(preg_woman_revision.object_changes) }

          it 'audits the change for eligible pregnant women' do
            preg_woman_changes['p_type_code'].should == [3, 14]
          end

          it 'records the change as coming from the 3.0 to 3.2 migration' do
            preg_woman_revision.whodunnit.should == described_class.to_s
          end
        end
      end
    end
  end
end
