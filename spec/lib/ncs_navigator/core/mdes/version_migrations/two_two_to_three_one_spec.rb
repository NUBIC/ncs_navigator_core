require 'spec_helper'

module NcsNavigator::Core::Mdes::VersionMigrations
  # clean_with_truncation because CodeListLoader#load_from_pg_dump hangs
  # when there's an open transaction that's touched ncs_codes.
  describe TwoTwoToThreeOne, :clean_with_truncation do
    include SurveyCompletion

    let(:migration) {
      TwoTwoToThreeOne.new
    }

    it 'goes from 2.2' do
      migration.from.should == '2.2'
    end

    it 'goes to 3.1' do
      migration.to.should == '3.1'
    end

  end
end
